package image_rpcs

import "github.com/Dev-Siri/wavelength/server/proto/imagepb"

type ImageService struct {
	imagepb.UnimplementedImageServiceServer
}

func NewImageService() *ImageService {
	return &ImageService{}
}
