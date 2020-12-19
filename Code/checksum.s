#
# CMPUT 229 Student Submission License
# Version 1.0
#
# Copyright 2020 <Afaq Nabi>
#
# Redistribution is forbidden in all circumstances. Use of this
# software without explicit authorization from the author or CMPUT 229
# Teaching Staff is prohibited.
#
# This software was produced as a solution for an assignment in the course
# CMPUT 229 - Computer Organization and Architecture I at the University of
# Alberta, Canada. This solution is confidential and remains confidential 
# after it is submitted for grading.
#
# Copying any part of this solution without including this copyright notice
# is illegal.
#
# If any portion of this software is included in a solution submitted for
# grading at an educational institution, the submitter will be subject to
# the sanctions for plagiarism at that institution.
#
# If this software is found in any public website or public repository, the
# person finding it is kindly requested to immediately report, including 
# the URL or other repository locating information, to the following email
# address:
#
#          cmput229@ualberta.ca
#
#---------------------------------------------------------------
# CCID:           	Nabi1@ualberta.ca      
# Lecture Section:      A1
# Instructor:           J. Nelson Amaral
# Lab Section:          D06
# Teaching Assistant:   Quinn Pham
#---------------------------------------------------------------


#.include "common.s"

#----------------------------------
#        STUDENT SOLUTION
#----------------------------------


# a0: starting address of an IP packet in memory.
checksum:
addi	sp, sp, -28 		# allocate space in the stack

# store all the s-registers to th allocated stack space and return address
sw	ra, 0(sp)
sw	s0, 4(sp)
sw	s1, 8(sp)
sw	s2, 12(sp)
sw	s3, 16(sp)
sw	s4, 20(sp)
sw	s5, 24(sp)

add	s0, zero, zero 		# initialize accumulator s0<- accumulator
add	s1, a0, zero 		# move a0 to s1
jal	getHeaderLength		# get the header length with a0 as function param

# temp function to come back from the get header length function
temp:
mv	s2, a0 			# s2 = packetheader legnth
slli	s2, s2, 1 		# s2*2 b/c we are adding halfwords
add	s4, zero, zero		# i = 0 s4<- i

lh	a0, 10(s1)		# load the headerchecksum field and reverse it
mv	t1, a0			# move the half word to t1
andi	t2, t1, 0x0FF		# 0000 0000 bbbb bbbb
slli	t2, t2, 8		# bbbb bbbb 0000 0000
li	t4, 0x0000FF00		# store value for the mask
and	t3, t1, t4		# bbbb bbbb 0000 0000
srli	t3, t3, 8		# 0000 0000 bbbb bbbb
or	t1, t2, t3		# bitwise or to store the reversed word in t1
mv	t6, t1			# move the reversed halfword to t6

lh	a0, 0(s1) 		# load halfword from s1 into a0
jal	flipHalfwordBytes	# flip the halfword

loop:
beq	a0, t6, skip		# check if the halfword is the header cheksum field
mv	t5, a0 			# move halfword to t5
add	s0, s0, t5		# add the half word to the acumulator
srli	t1, s0, 16		# check carry out
add	s0, s0, t1		# add carry out
slli	s0, s0, 16		# shift the accumulator left 
srli	s0, s0, 16		# shift the accumulator back left to get rid of the upper 16 bits
addi	s4, s4, 1		# i++
beq	s2, s4, exit		# if i>= packet header length
addi	s1, s1, 2 		# increment the ip packet
lh	a0, 0(s1) 		# load halfword from s1 into a0
jal	flipHalfwordBytes	# flip the halfword

skip:
addi	s4, s4, 1		# i++
beq	s2, s4, exit		# if i>= packet header length
addi	s1, s1, 2 		# increment the ip packet
lh	a0, 0(s1) 		# load halfword from s1 into a0
jal	flipHalfwordBytes	# flip the halfword

# reverse the halfword
flipHalfwordBytes: 		# flip the half word bytes and reverse the order
mv	t1, a0			# move the half word to t1
andi	t2, t1, 0x0FF		# 0000 0000 bbbb bbbb
slli	t2, t2, 8		# bbbb bbbb 0000 0000
li	t4, 0x0000FF00		# store value for the mask
and	t3, t1, t4		# bbbb bbbb 0000 0000
srli	t3, t3, 8		# 0000 0000 bbbb bbbb
or	t1, t2, t3		# bitwise or to store the reversed word in t1
# move t1 to a0 to pass back to the loop function
mv	a0, t1 			# move the packet header length to ao0 to be returend 
jal	loop			# jump

getHeaderLength: 		# i think it is good??
add	t0, a0, zero  		# store the IP packet in t0
lh	t1, 0(t0) 		# load the packet header leangth into t1
andi	t1, t1, 0x0000000F 	# mask to get the value of packet header length
mv	a0, t1 			# move the packet header length to ao0 to be returend
jal 	temp 			# jump back to checksum function

# exit the programs
exit:
li	t6, 0x0000FFFF		# store to bitwise not
xor	s0, s0, t6		# complement of the accumulator
mv	a0, s0			# store accumulator to a0 to be returned 

# restore the s-registers and deallocate the space on the stack
lw	ra, 0(sp)
lw	s0, 4(sp)
lw	s1, 8(sp)
lw	s2, 12(sp)
lw	s3, 16(sp)
lw	s4, 20(sp)
lw	s5, 24(sp)
addi	sp, sp, 28

jalr 	zero, ra, 0 		# jump back to checksum function
