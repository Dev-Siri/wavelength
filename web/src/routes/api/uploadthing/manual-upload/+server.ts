import { PRIVATE_UPLOADTHING_KEY } from "$env/static/private";
import { error, json } from "@sveltejs/kit";

import { UPLOADTHING_API_URL } from "$lib/constants/urls.js";
import queryClient from "$lib/utils/query-client.js";

interface UploadThingResponse {
  data: {
    key: string;
    fileName: string;
    fileType: string;
    fileUrl: string;
    contentDisposition: string;
    pollingJwt: string;
    pollingUrl: string;
    customId?: string;
    url: string;
    fields: Record<string, string>;
  }[];
}

export async function POST({ request }) {
  const body = await request.blob();

  const generatedFileName = `m_upload-${crypto.randomUUID()}`;

  try {
    const uploadFilesResponse = await queryClient<UploadThingResponse>(
      UPLOADTHING_API_URL,
      "/v6/uploadFiles",
      {
        method: "POST",
        headers: {
          "X-Uploadthing-Api-Key": PRIVATE_UPLOADTHING_KEY,
        },
        body: {
          files: [
            {
              name: generatedFileName,
              size: body.size,
              type: body.type,
              customId: null,
            },
          ],
          acl: "public-read",
          metadata: null,
          contentDisposition: "inline",
        },
      },
    );

    const data = uploadFilesResponse.data[0];

    const formData = new FormData();

    Object.entries(data.fields).forEach(([key, value]) => formData.append(key, value));

    formData.append("file", body, generatedFileName);

    const uploadResponse = await fetch(data.url, {
      method: "POST",
      body: formData,
    });

    if (uploadResponse.status !== 204) throw new Error();

    return json({
      success: true,
      data: {
        url: data.fileUrl,
        key: data.key,
        name: data.fileName,
      },
    });
  } catch {
    error(500, {
      success: false,
      message: "An error occured while uploading the image.",
    });
  }
}
