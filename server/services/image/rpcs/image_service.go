package image_rpcs

import "wavelength/proto/imagepb"

type ImageService struct {
	imagepb.UnimplementedImageServiceServer
}

func NewImageService() *ImageService {
	return &ImageService{}
}
