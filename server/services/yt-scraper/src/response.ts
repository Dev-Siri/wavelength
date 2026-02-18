import * as grpc from "@grpc/grpc-js";

export function createErrorResponse(
  message: string,
  code: grpc.status = grpc.status.INTERNAL,
) {
  return new grpc.StatusBuilder().withCode(code).withDetails(message).build();
}
