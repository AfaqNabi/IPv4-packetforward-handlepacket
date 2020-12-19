
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
# CCID:                 nabi1@ualberta.ca
# Lecture Section:      A1
# Instructor:           J. Nelson Amaral
# Lab Section:          D06
# Teaching Assistant:   Quin Pham
#---------------------------------------------------------------
# 

.include "common.s"
.include "checksum.s"

#----------------------------------
#        STUDENT SOLUTION
#----------------------------------

handlePacket:
# a0: starting address of an IP packet in memory.
addi	sp, sp, -8		# make room in the stack
sw	ra, 0(sp)		# store ra on the stack
sw	s2, 4(sp) 		# store s2 on the stack

add	s2, a0, zero  		# move a0 to s2

# validate IP version
mv	a0, s2 			# move the IP packet to a0
jal	ra, validateIP 		# jump to validateIP
beq	a0, x0, exit2

# validate TTL
mv	a0, s2 			# move IP packet to a0 
jal	ra, validateTTL 	# call validate TTL
beq	a0, x0, exit1 		# exit program if TTL=1

# validate checksum
mv	a0, s2 			# move IPpacket(s2) to a0
jal	ra, validateChecksum 	# jump to validate checksum
beq	a0, x0, exit0 		# exit program if checksum doesnt match

# if Packet should be forwarded
lb	t2, 8(s2) 		# laod the TTL field
addi	t2, t2, -1 		# decrement it 
sb	t2, 8(s2) 		# store it back into the ip packet

mv	a0, s2 			# move IPpacket(s2) to a0
jal	ra, checksum		# recalculate checksum

mv	t1, a0			# move the half word to t1
andi	t2, t1, 0x0FF		# 0000 0000 bbbb bbbb
slli	t2, t2, 8		# bbbb bbbb 0000 0000
li	t4, 0x0000FF00		# store value for the mask
and	t3, t1, t4		# bbbb bbbb 0000 0000
srli	t3, t3, 8		# 0000 0000 bbbb bbbb
or	t1, t2, t3		# bitwise or to store the reversed word in t1

# move t1 to a0 to pass back to the loop function
mv	a0, t1 			# move the packet header length to ao0 to be returend 

mv	a1, s2			# store ip packet to a1
lh	t1, 10(a1)		# get header checksum
mv	t1, a0			# mvoe new header checksum
sh	t1, 10(a1)		# update header checksum

addi	t6, zero, 1 		# t6 = 1
mv	a0, t6 			# move s1 to a0

mv	a1, s2 			# move ip packet(s2) to a1

lw	ra, 0(sp)		# store ra on the stack
lw	s2, 4(sp) 		# store s2 on the stack
addi	sp, sp, 8		# restore stack pointer

jalr 	zero, ra, 0 		# jump to caller

validateIP:
add	t0, a0, zero 		# load a0 into t0
lb	t1, 0(t0) 		# load ip version into t1
srli	t1, t1, 4 		# shift out the lower four bits

addi	t2, zero, 4 		# add 4 to t2

beq	t2, t1, store1  	# if IP version is 4 jump

mv	a0, zero 		# else store zero into a0 and return
jalr	zero, ra, 0 		# jump to handle packet

store1:
addi	t4, zero, 1 		# t4 = 1
mv	a0, t4 			# a0 = s1

jalr	zero, ra, 0 		# jump back to handlePacket

validateTTL:
add	t1, a0, x0 		# move IP packet to t1
addi	t5, zero, 1 		# add 1 to t5
lbu	t2, 8(t1) 		# load the TTL into t2

bgt	t2, t5, store2 		# check if TTL>1

mv	a0, x0 			# put zero in a0
jalr	zero, ra, 0 		# jump to ra

store2:
addi	t2, zero, 1 		# s1 = 1
mv	a0, t2 			# store 1 into a0

jalr	zero, ra, 0 		# jump to ra

validateChecksum:
addi	sp, sp, -8 		# make room on the stack
sw	ra, 0(sp) 		# store ra on the stack
sw	s3, 4(sp) 		# store s3 on the stack

lh	t1, 10(a0)		# load the headerchecksum field and reverse it
andi	t2, t1, 0x0FF		# 0000 0000 bbbb bbbb
slli	t2, t2, 8		# bbbb bbbb 0000 0000
li	t4, 0x0000FF00		# store value for the mask
and	t3, t1, t4		# bbbb bbbb 0000 0000
srli	t3, t3, 8		# 0000 0000 bbbb bbbb
or	t1, t2, t3		# bitwise or to store the reversed word in t1
mv	s3, t1			# move the reversed halfword to t6
jal	ra, checksum 		# find checksum
mv 	t4, a0 			# move a0 to t4
beq	s3, t4, store3 		# check if checksum = header checksum

lw	ra, 0(sp) 		# restore ra
lw	s3, 4(sp) 		# restore s3
addi	sp, sp, 8 		# reallocate the stack 

mv	a0, x0 			# move zero to a0
jalr	zero, ra, 0 		# jump to ra

store3:
addi	t6, zero, 1 		# s1 = 1

mv	a0, t6 			# a0 = 1

lw	ra, 0(sp) 		# restore ra
lw	s3, 4(sp) 		# restore s3
addi	sp, sp, 8 		# reallocate the stack 
jalr	zero, ra, 0 		# jump to ra

exit0:
lw	ra, 0(sp)		# store ra on the stack
lw	s2, 4(sp) 		# store s2 on the stack
addi	sp, sp, 8		# make room in the stack

mv	a0, x0 			# a0 = 0 
mv	a1, x0 			# a1 = 0
jalr 	zero, ra, 0 		# jump back to caller

exit1:
lw	ra, 0(sp)		# store ra on the stack
lw	s2, 4(sp) 		# store s2 on the stack
addi	sp, sp, 8		# make room in the stack

addi	t4, zero, 1		# t4 = 1
mv	a0, x0 			# a0 = 0
mv	a1, t4 			# a1 = 1
jalr 	zero, ra, 0 		# jump to caller

exit2:
lw	ra, 0(sp)		# store ra on the stack
lw	s2, 4(sp) 		# store s2 on the stack
addi	sp, sp, 8		# make room in the stack

addi	t6, zero, 2 		# t6 = 2
mv	a0, x0 			# a0 = 0
mv	a1, t6			# a1 = 2
jalr 	zero, ra, 0 		# jump to caller
