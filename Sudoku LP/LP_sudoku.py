import pulp

# Initialize the problem
prob = pulp.LpProblem("Sudoku", pulp.LpMinimize)

# Decision variables
x = pulp.LpVariable.dicts("x", 
                        ((i, j, k) for i in range(1, 10) 
                                    for j in range(1, 10) 
                                    for k in range(1, 10)), 
                        cat="Binary")

# Objective function (no minimization goal)
prob += 0

# Constraints
# Cell constraints
for i in range(1, 10):
    for j in range(1, 10):
        prob += pulp.lpSum(x[(i, j, k)] for k in range(1, 10)) == 1

# Row constraints
for i in range(1, 10):
    for k in range(1, 10):
        prob += pulp.lpSum(x[(i, j, k)] for j in range(1, 10)) == 1

# Column constraints
for j in range(1, 10):
    for k in range(1, 10):
        prob += pulp.lpSum(x[(i, j, k)] for i in range(1, 10)) == 1

# Sub-grid constraints
for sub_i in range(0, 3):
    for sub_j in range(0, 3):
        for k in range(1, 10):
            prob += pulp.lpSum(x[(i, j, k)] 
                                for i in range(1 + sub_i * 3, 4 + sub_i * 3) 
                                for j in range(1 + sub_j * 3, 4 + sub_j * 3)) == 1

# Pre-filled cells (example: pre-filled cell (1, 1) = 5)
prefilled_cells = {(1, 8): 1, 
                    (2, 4): 9, (2, 7):6, (2,9):7,
                    (3,2):9, (3,5):8, (3,6):3, (3,8):5,
                    (5,2):5, (5,4):3, (5,8):2,
                    (6,1):9, (6,5):7, (6,6):1, (6,9):5,
                    (7,3):5, (7,4):1, (7,6):2,
                    (8,2):3, (8,8):6,
                    (9,4):7, (9,6):4, (9,9):8}  # Example values
for (i, j), k in prefilled_cells.items():
    prob += x[(i, j, k)] == 1

# Solve
prob.solve()

# Display solution
solution = [[0] * 9 for _ in range(9)]
for i in range(1, 10):
    for j in range(1, 10):
        for k in range(1, 10):
            if pulp.value(x[(i, j, k)]) == 1:
                solution[i - 1][j - 1] = k

for row in solution:
    print(row)
