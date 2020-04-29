#if the citizen's income was not higher than 85,528 thalers, 
#the tax was equal to 18% of the income minus 556 thalers and 2 cents
#if the income was higher than this amount, the tax was equal to 
#14,839 thalers and 2 cents, plus 32% of the surplus over 85,528 thalers.

income = float(input("Enter the annual income: "))
limit_income = 85528
tax_relief = 556.02
tax_over = 14839.02
magic_number = -1

if income <= limit_income:
    tax = ((income * 18)/100) - tax_relief 
    if tax <= -1:
        tax = 0.0
elif income > limit_income:
    income_surplus = income - limit_income
    tax = tax_over + ((income_surplus * 32)/100) 
else:
    tax = 0
 
tax = round(tax, 0)
print("The tax is:", tax, "thalers")
