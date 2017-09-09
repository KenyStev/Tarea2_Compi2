#############################################
# sum.py
# Sample program for testing while statement
#############################################
random.seed(time.clock())

total = 0
count = 0

while count < 3:
    number = random.randint(0, 100)
    print("Number ", count, " = ", number) 
    count = count + 1
    total = total + number
    pass
print ("The total is ", total)
