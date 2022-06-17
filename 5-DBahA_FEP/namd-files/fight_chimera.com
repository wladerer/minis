swapna G :7 & @/pdbSegment=D1
sel :7 & @/pdbSegment=D1
addh
swapna C :5 & @/pdbSegment=D2
sel :5 & @/pdbSegment=D2
addh
save