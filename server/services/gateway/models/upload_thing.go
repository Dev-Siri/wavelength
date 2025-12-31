package models

type UploadThingRequestFile struct {
	Name     string  `json:"name"`
	Size     int     `json:"size"`
	Type     string  `json:"type"`
	CustomId *string `json:"customId"`
}

type UploadThingRequestPayload struct {
	Files              []UploadThingRequestFile `json:"files"`
	Acl                string                   `json:"acl"`
	Metadata           *string                  `json:"metadata"`
	ContentDisposition string                   `json:"contentDisposition"`
}

type UploadThingResponse struct {
	Data []UploadThingResponseFile `json:"data"`
}

type UploadThingResponseFile struct {
	Key                string            `json:"key"`
	FileName           string            `json:"fileName"`
	FileType           string            `json:"fileType"`
	FileUrl            string            `json:"fileUrl"`
	ContentDisposition string            `json:"contentDisposition"`
	PollingJwt         string            `json:"pollingJwt"`
	PollingUrl         string            `json:"pollingUrl"`
	CustomId           string            `json:"customId"`
	Url                string            `json:"url"`
	Fields             map[string]string `json:"fields"`
}

type UploadThingManualFileUploadResponse struct {
	Url  string `json:"url"`
	Key  string `json:"key"`
	Name string `json:"name"`
}
