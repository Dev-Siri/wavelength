package image_rpcs

import (
	"context"
	"image"
	_ "image/jpeg"
	_ "image/png"
	"net/http"

	"github.com/Dev-Siri/wavelength/server/proto/commonpb"
	"github.com/Dev-Siri/wavelength/server/proto/imagepb"
	"github.com/Dev-Siri/wavelength/server/shared/logging"

	"github.com/cenkalti/dominantcolor"
	"go.uber.org/zap"
	_ "golang.org/x/image/webp"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
)

const coverEffectColorVariantCount = 10

// Cover effect colors are the N colors of the cover of the song. (N = coverEffectColorVariantCount)
// Unlike theme-color which is the dominant color, cover effect requires multiple
// in-addition to the theme (dominant) color to form a background with floating blurs.
func (i *ImageService) GetCoverEffectColors(
	ctx context.Context,
	request *imagepb.GetCoverEffectColorsRequest,
) (*imagepb.GetCoverEffectColorsResponse, error) {
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

	colors := dominantcolor.FindN(img, coverEffectColorVariantCount)

	themeColors := make([]*commonpb.ThemeColor, 0, len(colors))
	for _, color := range colors {
		themeColors = append(themeColors, &commonpb.ThemeColor{
			R: uint32(color.R),
			G: uint32(color.G),
			B: uint32(color.B),
		})
	}

	return &imagepb.GetCoverEffectColorsResponse{
		Colors: themeColors,
	}, nil
}
