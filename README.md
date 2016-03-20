# **R**emote **P**lotting **P**rotocol
A protocol and implementation for plotting over the network. Matlab based interface.

## Motivation
For the past 2 years I've been attempting to move away from Matlab for various math heavy projects (mostly homework based)
and start using the [D Programming Language](https://dlang.org). Of the many problems I have faced, one of the more irritating
and hard to solve ones was plotting. For all the flaws Matlab has, plotting is not one. It has a simple and intuitive interface
that makes generating quality plots easy. Now you may think plotting something can't be that hard right? Well for something
simple no, it isn't hard. But look at what Matlab offers just beyond basic plotting:
- latex formated labels for anything
- vector graphics output in many formats (pdf, eps, but no svg oddly enough)
- sub-plots in the same figure
- log scale plots with tick marks that actually work (looking at you plplot)

This just names some, but adequately illustrates the difficulties of effectively replicating such functionality. It is, to say the
least, non trivial.

## What is RPP
First and foremost, RPP is a protocol. It defines how a bag of bytes is interpreted. This protocol defines
a number of functions used to plot figures a la Matlab. Of course, a protocol definition does nobody any good without
an implementation so I've provided that as well. Currently there exist two server implementations and one client implementation.
There is a legacy Matlab server. This is the original server-side code I wrote in Matlab so I could start doing work. After
most of the current functionality was implemented I was faced with limitations of Matlab as programming language (not the fist time)
that degraded user experience (can't close figures till the script is killed or another connection is served) and would
make future desired functionality next to impossible. I did some research, found I could run Java code straight from Matlab
and started down the path of doing low-level IO in Java and pass data to Matlab to plot but after about 3 days with
Java I jumped off a bridge. After more research I discovered one could run Matlab as a library and thus the current server
implementation was born.

## State of the Protocol
There currently exists a client library written in D and a modular plugin based server. The server does all IO and data 
processing and passes the decoded data to a backend to do the actual plotting work. This allows for different plotting backends
(matplotlib for instance, which is being worked on) to be easily implemented without having to worry about what the protocol
actually is. The only plugin is the matlabBackend plugin.

 
