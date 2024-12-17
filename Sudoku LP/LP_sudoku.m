clc;
clear;

% Decision Variables
n = 9;
x = optimvar('x', n, n, n, 'Type', 'integer', 'LowerBound', 0, 'UpperBound', 1);

% Optimization Problem
prob = optimproblem;

% Constraints
% Each cell must contain exactly one number
cell_constraint = sum(x, 3) == 1;
prob.Constraints.cell = cell_constraint;

% Each row must contain each number exactly once
for k = 1:n
    prob.Constraints.(['row_', num2str(k)]) = sum(x(:, :, k), 2) == 1;
end

% Each column must contain each number exactly once
for k = 1:n
    prob.Constraints.(['col_', num2str(k)]) = sum(x(:, :, k), 1)' == 1;
end

% Each 3x3 subgrid must contain each number exactly once
for sub_i = 0:2
    for sub_j = 0:2
        for k = 1:n
            prob.Constraints.(['subgrid_', num2str(sub_i), '_', num2str(sub_j), '_', num2str(k)]) = ...
                sum(sum(x(sub_i*3+1:sub_i*3+3, sub_j*3+1:sub_j*3+3, k))) == 1;
        end
    end
end

% Pre-filled cells
prefilled_cells = [
    1, 8, 1;
    2, 4, 9; 2, 7, 6; 2, 9, 7;
    3, 2, 9; 3, 5, 8; 3, 6, 3; 3, 8, 5;
    5, 2, 5; 5, 4, 3; 5, 8, 2;
    6, 1, 9; 6, 5, 7; 6, 6, 1; 6, 9, 5;
    7, 3, 5; 7, 4, 1; 7, 6, 2;
    8, 2, 3; 8, 8, 6;
    9, 4, 7; 9, 6, 4; 9, 9, 8;
];

for i = 1:size(prefilled_cells, 1)
    row = prefilled_cells(i, 1);
    col = prefilled_cells(i, 2);
    digit = prefilled_cells(i, 3);
    prob.Constraints.(['prefilled_', num2str(i)]) = x(row, col, digit) == 1;
end

% Solve the Problem using intlinprog
intcon = 1:n*n*n;  % Indices of integer variables
f = zeros(n, n, n); % Objective function is zero (feasibility problem)
[x_sol, ~, exitflag] = solve(prob, 'Options', optimoptions('intlinprog', 'Display', 'off'));

% Extract the Sudoku Grid
if exitflag == 1
    sudoku_grid = zeros(n, n);
    for i = 1:n
        for j = 1:n
            for k = 1:n
                if x_sol.x(i, j, k) > 0.5  % Binary solution check
                    sudoku_grid(i, j) = k;
                end
            end
        end
    end
    disp('Solved Sudoku Grid:');
    disp(sudoku_grid);
else
    disp('No solution found or solver did not converge.');
end
