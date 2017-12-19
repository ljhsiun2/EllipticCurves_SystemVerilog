# Elgamal_ECC
Elgamal's over secp256k1 in SystemVerilog

# Background
ECE385 is the FPGA class at UIUC, and this is my final project for that class. The final projects in the class are graded by the difficulty of
the project, on a scale of 1-10. That is, a project of "Pong" would get a difficulty score of 1, whereas a project implementing the Apple Classic II
would be a score of 10. This score is up to the discretion of the TA grading the project.

My initial project proposal was to do an RSA implementation. I decided against it because 1) everybody under the sun does it (down to the same exact [board we have at UIUC](https://people.ece.cornell.edu/land/courses/ece5760/FinalProjects/f2011/clt67_yl478/clt67_yl478/index.html)) and 2) more importantly, my TA guesstimated the difficulty score to be a 5, but I couldn't settle for that, so 4-5 sleepless weeks later here's that 10/10 project.

**NOTE:** You definitely shouldn't use this jank code written by an undergrad in your commercial applications.

**NOTE 2:** Nor should you clone this repo for your own FPGA class. I've left hidden comments and module instantiations that, if left 
untouched, are obvious to a TA it's copied and pasted. So no cheating pls :)

# Project specific information
--secp256k1 parameters are hardcoded, but changing to another prime field curve is relatively trivial-- only bit sizes and "magic numbers" need
to be changed, and these magic numbers have comments next to them.

--The sent message is used as the x value to encode a message as a point on the curve. The message encoding involves the Tonelli-Shanks
algorithm, so ensure that *p* mod 4 === 3 (which should always be the case anyways if using secp curves).

--Chacha20 is used as the random number generator for private key generation. The seeds to the RNG are hardcoded, and have no real source
of entropy (e.g. a mouse or temperature)

--Scalar multiplication is done via double-and-add. It's recommended to do sliding-window and/or LUT or Montgomery ladder for either performance
or security.

--Encrypt and decrypt takes ~60ms and ~50ms respectively. 

--Final_top_2 and testbench_2 are the ModelSim files, final_top is the interface to the actual board. 
