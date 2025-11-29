package image_controllers

import (
	"bytes"
	"encoding/json"
	"io"
	"mime/multipart"
	"net/http"
	"path/filepath"
	"wavelength/constants"
	"wavelength/env"
	"wavelength/models"
	"wavelength/models/responses"

	"github.com/gofiber/fiber/v2"
	"github.com/google/uuid"
)

func ManualImageUpload(ctx *fiber.Ctx) error {
	imageBytes := ctx.Body()
	imageSize := len(imageBytes)
	imageType := ctx.Get("Content-Type")

	httpClient := &http.Client{}
	uploadThingKey := env.GetUploadThingKey()

	generatedFileName := "m_upload-" + uuid.New().String()

	payload := models.UploadThingRequestPayload{
		Files: []models.UploadThingRequestFile{
			{
				Name:     generatedFileName,
				Size:     imageSize,
				Type:     imageType,
				CustomId: nil,
			},
		},
		Metadata:           nil,
		Acl:                "public-read",
		ContentDisposition: "inline",
	}

	jsonPayload, err := json.Marshal(payload)

	if err != nil {
		return fiber.NewError(fiber.StatusInternalServerError, "An error occured while uploading the image: "+err.Error())
	}

	jsonPayloadBuffer := bytes.NewBuffer(jsonPayload)
	uploadFilesRequest, err := http.NewRequest(http.MethodPost, constants.UploadThingApiUrl+"/v6/uploadFiles", jsonPayloadBuffer)

	uploadFilesRequest.Header.Set("Content-Type", "application/json")
	uploadFilesRequest.Header.Add("X-Uploadthing-Api-Key", uploadThingKey)

	if err != nil {
		return fiber.NewError(fiber.StatusInternalServerError, "An error occured while uploading the image: "+err.Error())
	}

	uploadFilesResponse, err := httpClient.Do(uploadFilesRequest)

	if err != nil {
		return fiber.NewError(fiber.StatusInternalServerError, "An error occured while retrieving the image URL: "+err.Error())
	}

	defer uploadFilesResponse.Body.Close()

	var uploadThingResponse models.UploadThingResponse

	bodyBytes, err := io.ReadAll(uploadFilesResponse.Body)

	if err != nil {
		return fiber.NewError(fiber.StatusInternalServerError, "Failed to read upload response: "+err.Error())
	}

	if err = json.Unmarshal(bodyBytes, &uploadThingResponse); err != nil {
		return fiber.NewError(fiber.StatusInternalServerError, "Failed to parse upload response: "+err.Error())
	}

	data := uploadThingResponse.Data[0]

	// Uploading to UploadThing.
	var formBuffer bytes.Buffer
	writer := multipart.NewWriter(&formBuffer)

	for key, value := range data.Fields {
		_ = writer.WriteField(key, value)
	}

	fileWriter, err := writer.CreateFormFile("file", filepath.Base(generatedFileName))

	if err != nil {
		return err
	}

	if _, err = fileWriter.Write(imageBytes); err != nil {
		return err
	}

	if err = writer.Close(); err != nil {
		return err
	}

	req, err := http.NewRequest("POST", data.Url, &formBuffer)
	if err != nil {
		return err
	}

	req.Header.Set("Content-Type", writer.FormDataContentType())

	client := &http.Client{}
	resp, err := client.Do(req)
	if err != nil {
		return err
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusNoContent {
		return fiber.NewError(fiber.StatusInternalServerError, "An error occured while uploading the image.")
	}

	return ctx.Status(fiber.StatusCreated).JSON(responses.Success(
		models.UploadThingManualFileUploadResponse{
			Url:  data.Url,
			Key:  data.Key,
			Name: data.FileName,
		}))
}
