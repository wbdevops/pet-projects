#Simple matrix with emoji
row1 = ["⬜️","⬜️","⬜️"]
row2 = ["⬜️","⬜️","⬜️"]
row3 = ["⬜️","⬜️","⬜️"]

#Declare a nested list
map = [row1, row2, row3]

#Concatenate all lists and build matrix
print(f"{row1}\n{row2}\n{row3}")

#Give 2 digits
position = input("Where do you want to put the treasure? ")

column_number = int(position[0])
row_number = int(position[1])

#Find necessary row
row = map[row_number -1]

#Add X in necessary place
row[column_number - 1] = "X"

print(f"{row1}\n{row2}\n{row3}")