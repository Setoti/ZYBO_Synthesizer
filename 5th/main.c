#include "xparameters.h"
#include "xiic.h"
#include "xil_printf.h"
#include "xgpio.h"
#include <sleep.h>

enum adauRegisterAddresses {
	R0_LEFT_ADC_VOL		= 0x00,
	R1_RIGHT_ADC_VOL	= 0x01,
	R2_LEFT_DAC_VOL		= 0x02,
	R3_RIGHT_DAC_VOL	= 0x03,
	R4_ANALOG_PATH		= 0x04,
	R5_DIGITAL_PATH		= 0x05,
	R6_POWER_MGMT		= 0x06,
	R7_DIGITAL_IF		= 0x07,
	R8_SAMPLE_RATE		= 0x08,
	R9_ACTIVE			= 0x09,
	R15_SOFTWARE_RESET	= 0x0F,
	R16_ALC_CONTROL_1	= 0x10,
	R17_ALC_CONTROL_2	= 0x11,
	R18_ALC_CONTROL_2	= 0x12
};

int CodecWrite(XIic*, u8 Address, u16 data);
XStatus CodecInit(XIic *Iic);

int main(void){
	XIic Iic;
	XGpio Gpio0, Gpio1;
	int status;

	xil_printf("IIC Start\n");

	// Codec Initialization
	status = CodecInit(&Iic);
	if(status != XST_SUCCESS) {
		xil_printf("Error Codec Initialization");
		return XST_FAILURE;
	}

	// AXI GPIO Initialization
	status = XGpio_Initialize(&Gpio0, XPAR_GPIO_0_DEVICE_ID);
	if(status != XST_SUCCESS) {
		return XST_FAILURE;
	}
	status = XGpio_Initialize(&Gpio1, XPAR_GPIO_1_DEVICE_ID);
	if(status != XST_SUCCESS){
		return XST_FAILURE;
	}

	// Port Direction
	XGpio_SetDataDirection(&Gpio0, 1, 0x0);  // output
	XGpio_SetDataDirection(&Gpio1, 1, 0x00); // output

	// Output Level
	XGpio_DiscreteWrite(&Gpio0, 1, 0xF);   // All lights up
	XGpio_DiscreteWrite(&Gpio1, 1, 0x1B8); // Set to 440Hz

	xil_printf("IIC Finished\n");
	return XST_SUCCESS;
}

// Write Audio Codec Register
int CodecWrite(XIic* Iic, u8 Address, u16 data){
	u8 Device_Address = 0x1A;       // Device ID
	UINTPTR BaseAddress = Iic->BaseAddress; // AXI IIC BaseAddress
	int num;                        // Number of Data sent

	// set write date
	u8 WR_data[2];
	Address = ((Address<<1) & 0xFE);
	WR_data[0] = Address + ((data>>8)&0x01);
	WR_data[1] = (data&0xFF);

	// send data
	num = XIic_Send(BaseAddress, Device_Address, WR_data, 2, XIIC_STOP);
	if(num!=2){
		xil_printf("Writing data Failed\r\n");
		return XST_FAILURE;
	}
	return XST_SUCCESS;
}

// Audio Codec Initialization
XStatus CodecInit(XIic* Iic){
	int status;

	// Initializes XIic instance.
	status = XIic_Initialize(Iic, XPAR_IIC_0_DEVICE_ID);
	if (status != XST_SUCCESS){
		return XST_FAILURE;
	}

	// Codec register settings
	CodecWrite(Iic, R6_POWER_MGMT,    0x77); // power on
	CodecWrite(Iic, R0_LEFT_ADC_VOL,  0x97);
	CodecWrite(Iic, R1_RIGHT_ADC_VOL, 0x97);
	CodecWrite(Iic, R2_LEFT_DAC_VOL,  0x79);
	CodecWrite(Iic, R3_RIGHT_DAC_VOL, 0x79);
	CodecWrite(Iic, R4_ANALOG_PATH,   0x10);
	CodecWrite(Iic, R5_DIGITAL_PATH,  0x00);
	CodecWrite(Iic, R7_DIGITAL_IF,    0x53);
	CodecWrite(Iic, R8_SAMPLE_RATE,   0x41);
	usleep(80000);  // wait for charging capacity on the VMID pin t=C*25000/3.5
	CodecWrite(Iic, R9_ACTIVE,        0x01);  // digital core active
	CodecWrite(Iic, R6_POWER_MGMT,    0x67);
	return XST_SUCCESS;
}
