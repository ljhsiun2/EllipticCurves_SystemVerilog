#include <stdlib.h>
#include <stdio.h>

volatile unsigned int * ECC_PTR = (unsigned int *) 0x00000080;

int main() {

	int i;

	unsigned long msg[8];

	unsigned long bobPriv[8];
	unsigned long bobX[8];
	unsigned long bobY[8];
	unsigned long alicePriv[8];
	unsigned long aliceX[8];
	unsigned long aliceY[8];

	unsigned long msgEncX[8];
	unsigned long msgEncY[8];
	unsigned long msgDecX[8];
	unsigned long msgDecY[8];

	while(1){

	ECC_PTR[30] = 0;
	printf("Type a 32 hex character message");
	scanf("%s", &msg);


	//Start
	ECC_PTR[30] = 1;

	for(i = 0; i < 8; i++) {
		ECC_PTR[i] = msg[i];
	}

	ECC_PTR[30] = 2;

	ECC_PTR[30] = 3;

	while(ECC_PTR[31] == 0) {
		//Wait for private key gen to finish
//		printf("Done = %lX\n", ECC_PTR[31]);
	}

	//Print out Alice private key
	printf("Alice's Private Key:0x");
	for(i = 0; i < 8; i++) {
		alicePriv[i] = ECC_PTR[8 + i];
		printf("08%lX", alicePriv[i]);
	}
	printf("\n");

	ECC_PTR[30] = 4;

	while(ECC_PTR[31] == 0) {
		//Wait for private key gen to finish
	}

	printf("Bob's Private Key:0x");
	for(i = 0; i < 8; i++) {
		bobPriv[i] = ECC_PTR[8 + i];
		printf("08%lX", bobPriv[i]);
	}
	printf("\n");

	ECC_PTR[30] = 5;

	while(ECC_PTR[31] == 0) {
		//Wait for private key gen to finish
	}

	printf("Bob's Public Key: X=:0x");
	for(i = 0; i < 8; i++) {
		bobX[i] = ECC_PTR[8 + i];
		printf("08%lX", bobX[i]);
	}
	printf("\n");

	//Toggle Sttart
	ECC_PTR[30] = 6;

	while(ECC_PTR[31] == 0) {
		//Wait for private key gen to finish
	}

	printf("Bob's Public Key: Y=:0x");
	for(i = 0; i < 8; i++) {
		bobY[i] = ECC_PTR[8 + i];
		printf("08%lX", bobY[i]);
	}
	printf("\n");

	ECC_PTR[30] = 7;

	while(ECC_PTR[31] == 0) {
		//Wait for private key gen to finish
	}

	printf("Alice's Public Key: X=:0x");
	for(i = 0; i < 8; i++) {
		aliceX[i] = ECC_PTR[8 + i];
		printf("08%lX", aliceX[i]);
	}
	printf("\n");

	ECC_PTR[30] = 8;

	while(ECC_PTR[31] == 0) {
		//Wait for private key gen to finish
	}

	printf("Alice's Public Key: Y=:0x");
	for(i = 0; i < 8; i++) {
		aliceY[i] = ECC_PTR[8 + i];
		printf("08%lX", aliceY[i]);
	}
	printf("\n");

	ECC_PTR[30] = 9;

	while(ECC_PTR[31] == 0) {
		//Wait for private key gen to finish
	}

	printf("Encrypted Message: X=:0x");
	for(i = 0; i < 8; i++) {
		msgEncX[i] = ECC_PTR[8 + i];
		printf("08%lX", msgEncX[i]);
	}
	printf("\n");

	ECC_PTR[30] = 10;

	while(ECC_PTR[31] == 0) {
		//Wait for private key gen to finish
	}

	printf("Encrypted Message: Y=:0x");
	for(i = 0; i < 8; i++) {
		msgEncY[i] = ECC_PTR[8 + i];
		printf("08%lX", msgEncY[i]);
	}
	printf("\n");

	ECC_PTR[30] = 11;

	while(ECC_PTR[31] == 0) {
		//Wait for private key gen to finish
	}

	printf("Decrypted Message: X=:0x");
	for(i = 0; i < 8; i++) {
		msgDecX[i] = ECC_PTR[8 + i];
		printf("08%lX", msgDecX[i]);
	}
	printf("\n");

	ECC_PTR[30] = 12;

	while(ECC_PTR[31] == 0) {
		//Wait for private key gen to finish
	}

	printf("Encrypted Message: X=:0x");
	for(i = 0; i < 8; i++) {
		msgDecY[i] = ECC_PTR[8 + i];
		printf("08%lX", msgDecY[i]);
	}
	printf("\n");
	ECC_PTR[30] = 15;
	}

}
