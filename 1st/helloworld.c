#include "xparameters.h"
#include "xgpio.h"
#include "xil_printf.h"

int main(void){

	int status;
	XGpio Gpio;

	// Serial transfer Hello World 
	xil_printf("Hello World. \n");

	/* GPIO Initialization */
	// Initial setting of Gpio variables
	status = XGpio_Initialize(&Gpio, XPAR_GPIO_0_DEVICE_ID);
	if(status != XST_SUCCESS) return XST_FAILURE;

	// I/O settings
	// 2nd arg：　Interface to configure  1:GPIO 2:GPIO2
	// 3rd arg：　I/O settings for each port  0:Out  1:In
	XGpio_SetDataDirection(&Gpio, 1, 0x0); // All set to Out

	// Signal level settings
	// 2nd arg：　Interface to configure  1:GPIO 2:GPIO2
	// 3rd arg：　the output level settings for each port  0:Low  1:High
	XGpio_DiscreteWrite(&Gpio, 1, 0xF); // All set to High
}