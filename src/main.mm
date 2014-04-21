
#import "oculus-rest.h"

using namespace OVR;

static int ahc_echo(void * cls, struct MHD_Connection * connection, const char * url, const char * method, const char * version, const char * upload_data, size_t * upload_data_size, void ** ptr) {
	static int dummy;
	// const char * page = (const char *)cls;
	struct MHD_Response * response;
	int ret;

	if (0 != strcmp(method, "GET"))
		return MHD_NO; /* unexpected method */
	if (&dummy != *ptr) {
		/* The first time only the headers are valid,
		do not respond in the first round... */
		*ptr = &dummy;
		return MHD_YES;
	}
	if (0 != *upload_data_size)
		return MHD_NO; /* upload data in a GET!? */
	*ptr = NULL; /* clear context pointer */

	Quatf q = pFusionResult->GetOrientation();
	// Matrix4f bodyFrameMatrix(q); 
	float yaw, pitch, roll;
	q.GetEulerAngles<Axis_Y, Axis_X, Axis_Z>(&yaw, &pitch, &roll);
	char json[300] = { 0, };
	sprintf(json, "{\"quat\":{\"x\":%1.7f,\"y\":%1.7f,\"z\":%1.7f,\"w\":%1.7f},\"euler\":{\"y\":%1.7f,\"p\":%1.7f,\"r\":%1.7f}}", q.x, q.y, q.z, q.w, yaw, pitch, roll);
	printf("SEND: %s\n", json);
	response = MHD_create_response_from_data(strlen(json), (void*) &json, MHD_NO, MHD_YES);
	MHD_add_response_header (response, "Content-Type", "application/json");
	MHD_add_response_header (response, "Access-Control-Allow-Origin", "*");
	ret = MHD_queue_response(connection, MHD_HTTP_OK, response);
	MHD_destroy_response(response);
	return ret;
}



@interface OVRApp : NSApplication
- (void) run;
@end

@implementation OVRApp

- (void)run {
    NSLog(@"Hello!");
    
    // Initialize Oculus Rift SDK
    
    // Initializes LibOVR.
    System::Init();
    
    pFusionResult = new SensorFusion();
 	pManager = *DeviceManager::Create();
	pHMD = *pManager->EnumerateDevices<HMDDevice>().CreateDevice();
	
    if (pHMD) {
        InfoLoaded = pHMD->GetDeviceInfo(&Info);
        pSensor  = *pHMD->GetSensor();
		HMDInfo hmdInfo;
        pHMD->GetDeviceInfo(&hmdInfo);
	}
    else{
        printf("No HMD found.\n");
    }
    
	if (pSensor)
		pFusionResult->AttachToSensor(pSensor);
    

   	struct MHD_Daemon * d;
	d = MHD_start_daemon(MHD_USE_THREAD_PER_CONNECTION, 50000, NULL, NULL, &ahc_echo, NULL, MHD_OPTION_END);
	if (d == NULL) {
		printf("Unable to start webserver.\n");
		return;
	}
	while(true) {
		sleep(1000);
	}
	MHD_stop_daemon(d);
	pSensor.Clear();
	pHMD.Clear();
	pManager.Clear();
	OVR::System::Destroy();
}
@end

int main(int argc, char *argv[])
{
    NSApplication* nsapp = [OVRApp sharedApplication];
    [nsapp run];
    return 0;
}




