#!/bin/sh

ipfw -q add 1010 allow tcp from  any to me 3306 via bge0
ipfw -q add 1011 allow tcp from me 3306 to any via bge0

