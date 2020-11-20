# vga_project

So, you wanna work on the VGA project? Awesome! A couple of tips to help you get started because I did not comment my code very well at all and it might be confusing.

For those of you working on sprite animation, the latest commit to top.v has the sprite animation code in it, but it is commented out. Some aspects of the code may be unclear to some of you so if you need to reach me to ask any questions at all, my email is tishbik1@tcnj.edu . Also, make sure you delete the portion of my code in top.v that has to do with line drawing.

There used to be a design source for the project called clock_divider.v and I urge you not to use it. Delete it from your project, this component was replaced by the clock wizard IP.

For simulation purposes, it might benefit you to use an alternate set of timings that will help you determine whether or not your code is working without having to wait 20 minutes to see real results in your simulation (it takes about 17 ms to write each frame which is FOREVER in hardware and many of your projects will need to simulate more than one frame for code verification purposes). The simulation timing values have been edited out and there is a comment I have put. Uncomment them for simulation and use the real values if you run synthesis/implementation.

For those of you seeking to run synthesis/implementation and really test your designs on a monitor, you will need to make sure you have added the constraints file to your project! The constraints file is here on GitHub, make sure the things you want have been correctly commented/uncommented. If you need help loading the bitstream onto your FPGA if you have a Mac, here is a helpful link: https://github.com/byu-cpe/BYU-Computing-Tutorials/wiki/Program-7-Series-FPGA-from-a-Mac-or-Linux-Without-Xilinx.
