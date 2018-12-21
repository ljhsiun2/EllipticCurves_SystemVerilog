# What is this?
This is the current working repository of my implementation of various ellptic curve protocols in SystemVerilog. This originally started out as a project for one of my classes where we were to do "literally anything on an FPGA" (exact quote), so I did this. I realized it had some potential, plus it was super fun to work in the low-level design space of an FPGA.

Furthermore, one of my frustrations with reading research papers is the lack of any code or ability to reproduce results. While I'm sure experts in the field would probably find code redundant or unnecessary, the lack of code restrains reproducability and discourages novices (like myself) from playing and learning from that code. This repo is meant to address that by giving some semblance of what hardware implementations of cryptography can **sometimes** look like.

# That sounds cool! But how can I use it/what can this be used for?
First, I recommend looking at the evaluation before deciding if you *really* want to use this. As mentioned, this is still very much a WIP, and while barebones functionality is achieved, it is nowhere near fast nor secure enough for actual use. 

With that said, the most appealing reason to have elliptic curve cryptography on an FPGA is its potential speed and energy efficiency that is impossible for any normal CPU (and by extension, any C implementation) to achieve. As an example, [this paper](https://ieeexplore.ieee.org/document/5542723) proposes an FPGA implementation that achieves over twice the throughput with a tenth of the energy cost  (65nm, .137GHz, 23W), compared to a normal CPU (45nm, 2.6GHz, 268W). 

Some applications of this might be:
  * Hardware accelerator for TLS (paper above)
  * Fast device in your blockchain, especially if you have lots of code updates
  * Coprocessor on IoT devices (e.g. Alexa)
  
  
  
# Evaluation
![Here](https://imgur.com/a/TmFmNsK) is 

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
