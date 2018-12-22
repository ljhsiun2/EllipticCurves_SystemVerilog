# What is this?
This is the current working repository of my implementation of various ellptic curve protocols in SystemVerilog. This originally started out as a project for one of my classes where we were to do "literally anything on an FPGA" (exact quote), so I did this. I realized it had some potential, plus it was super fun to work in the low-level design space of an FPGA.

Furthermore, one of my frustrations with reading research papers is the lack of any code or ability to reproduce results. While I'm sure experts in the field would probably find code redundant or unnecessary, the lack of code restrains reproducability and discourages novices (like myself) from playing and learning from that code. This repo is meant to address that by giving some semblance of what hardware implementations of cryptography can **sometimes** look like.

# That sounds cool! But how can I use it/what can this be used for?
First, I recommend looking at the evaluation before deciding if you *really* want to use this. As mentioned, this is still very much a WIP, and while barebones functionality is achieved, it is nowhere near fast nor secure enough for actual use. 

With that said, the most appealing reason to have elliptic curve cryptography on an FPGA is its potential speed and energy efficiency that is impossible for any normal CPU (and by extension, any C implementation) to achieve. As an example, [this paper](https://ieeexplore.ieee.org/document/5542723) proposes an FPGA implementation that achieves over twice the throughput with a tenth of the energy cost  (65nm, .137GHz, 23W), compared to a normal CPU (45nm, 2.6GHz, 268W). 

Some applications of this might be:
  * Hardware accelerator for TLS (paper above)
  * Fast device in your blockchain, especially if you have lots of code updates
  * [Coprocessor](https://www.researchgate.net/profile/Philip_Leong3/publication/2633178_FPGA_Implementation_of_a_Microcoded_Elliptic_Curve_Cryptographic_Processor/links/55507c6f08ae93634ec8dec1/FPGA-Implementation-of-a-Microcoded-Elliptic-Curve-Cryptographic-Processor.pdf) on IoT or embedded devices (e.g. Alexa)
  * An FPGA cluster to [break certain curves for fun](https://eprint.iacr.org/2009/541.pdf) or (solve discrete logs on curves faster)[https://cr.yp.to/dlog/sect113r2-20160806.pdf]
  
# Current Features
  * ECDSA
  * ElGamal's
  * ChaCha20 for PRNG
  * Customizable curve parameters (via components/elliptic_curve_structs)
  
### Wish List/Future Work
  * Timing/power security
  * Pipelined 
  * Speed optimizations (e.g. Montgomery form, Itoh-Tsujii's, Karatsuba's, Shamir's verif trick) 
  * Real board to obtain power metrics
  * Create real source of entropy (currently hardcoded seeds)
  * Implement Tonelli-Shanks fully (curve prime *p* currently must be == 3 mod 4)
  * Optimize critical path/max frequency

# Repository Structure
  - src/ -- bulk of EC modules
    - components/ -- basic components such as registers, project structs, etc.
    - ecdsa/ -- ECDSA top level
    - elgamal/ -- ElGamal's top level
    - primitives/ -- contains common base operations e.g. add, hash, point multiplication.
    - rng/ -- contains ChaCha20 implementation
  - images/ -- images for README
  - misc/ -- scripts and values for comparing functionality
  - testbenches/ -- testbenches for running modules
  - final_top.sv -- top level module for running protocol(s)
  
# Function Flow
![](https://raw.githubusercontent.com/ljhsiun2/EllipticCurves_SystemVerilog/readme-changes/images/Capture.PNG) Here is a closer look at how ECDSA is implemented. Note that any multiplies and additions are done with the multiplier.sv and add.sv in src/primitives/modular_operations/


# Evaluation
![](https://raw.githubusercontent.com/ljhsiun2/EllipticCurves_SystemVerilog/readme-changes/images/Capture2.PNG) Here is a simulation of the ECDSA signing implementation run at 1GHz. The signature finishes in ~5ms, or about 5 million cycles. [Crypto++ v5.6](https://www.cryptopp.com/benchmarks.html) runs ECDSA over a 256-bit curve in ~3ms, or about 5.27 million cycles on an Intel Core 2. At the time of this writing, the latest version of Crypto++ is v7.0, which don't seem to have benchmarks available yet. I was unable to find power or area metrics for the tested cores running these at the time of writing.

While it may appear that my implementation is fast, keep in mind it is still very insecure, and that the Intel Core 2 is a core from 2006.

**Note:** Crytpo++ used to have [this page](https://web.archive.org/web/20181107125125/https://www.cryptopp.com/benchmarks.html) as its benchmarks which evaluated Crypto++ v6.0 on a Skylake-i5. I'm not sure why they have v5.6 benchmarks currently displayed on a 2006 processor. Regardless, the removed benchmarks are linked above.


# Project specific information

-- Created on Quartus 18.1 Lite Edition

-- The sent message is used as the x value to encode a message as a point on the curve. The message encoding involves the Tonelli-Shanks
algorithm, so ensure that *p* mod 4 === 3 (which should always be the case anyways if using secp curves).

-- Seeds to ChaCha20 are hardcoded due to the lack of any real board (and thus real entropy source).

# Challenges and Lessons
This section is to primarily detail some of the challenges I've faced in creating this repo and are not relevant to general functionality.

  * __Implementation__ : Many implementation details are left out of papers for sake of conciseness and repetitiveness. For instance, many modules explicity require a done state or "enable" signal, since intermediate inputs in any module with combinational logic will affect its output. Those more experienced may find this obvious, but still one that was fun to find out.
  
  * __Integration__ : Some modules are unnecessary to reimplement as they are (somewhat) widely available in Verilog, such as SHA256. The issue initally with the repository I had used for SHA was that it didn't compile on Quartus 18 Lite, and so numerous modifications to the module were made to attain functionality. This took many more hours than I had expected, and the lesson is to never pull-and-plug random repositories without vetting it.
  
  * __Testing and Compilng__: Synthesis time takes ~30 minutes, ~15 minutes to run a simulation, and ~4 hours to get timing information. This is a barrier to testing some components of functionality, as even one small mistake can result in hours wasted, and required lots of patience on my part.
