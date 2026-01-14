package image_rpcs

import (
	"context"
	"image"
	"net/http"
	"wavelength/proto/commonpb"
	"wavelength/proto/imagepb"
	"wavelength/shared/logging"

	"github.com/cenkalti/dominantcolor"
	"go.uber.org/zap"
	_ "golang.org/x/image/webp"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
)

func (i *ImageService) GetThemeColor(
	ctx context.Context,
	request *imagepb.GetThemeColorRequest,
) (*imagepb.GetThemeColorResponse, error) {
	response, err := http.Get(request.ImageUrl)
	if err != nil {
		logging.Logger.Error("Image fetch failed.", zap.Error(err))
		return nil, status.Error(codes.Internal, "Image fetch failed.")
	}

	defer response.Body.Close()

	img, _, err := image.Decode(response.Body)
	if err != nil {
		logging.Logger.Error("Image decode failed.", zap.Error(err))
		return nil, status.Error(codes.Internal, "Image decode failed.")
	}

	color := dominantcolor.Find(img)
	return &imagepb.GetThemeColorResponse{
		ThemeColor: &commonpb.ThemeColor{
			R: uint32(color.R),
			G: uint32(color.G),
			B: uint32(color.B),
		},
	}, nil
}
