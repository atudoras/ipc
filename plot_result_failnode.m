function plot_result_failnode(x,y,N_out,N)
bar_width = 0.3;  % Width of each bar
bar_width_1 = 0.45;  % Width of each bar
bar_width_2 = 0.15;  % Width of each bar

% Plot the first bar with left y-axis
bar(x - bar_width + bar_width_1/2, y, bar_width_1)
hold on

% Activate the right y-axis for the second bar
yyaxis right
bar(x + bar_width/2+ bar_width_2/2, N_out, bar_width_2)
ylabel('Number of additional lost buses')

% Set the y-axis tick labels on the right to show only integers
ytickformat('%.0f')

% Set the y-axis limits to show only integer ticks
ylim_right = ylim;
ylim_right = ceil(ylim_right);  % Round up the upper limit to the nearest integer
ylim_right(1) = floor(ylim_right(1));  % Round down the lower limit to the nearest integer
ylim(ylim_right);

% Set the number of y-axis ticks on the right to match the number of unique integer values
yticks_right = unique([1:max(N_out)]);
yticks_right = yticks_right(rem(yticks_right, 1) == 0);  % Keep only the integer values
yticks(yticks_right);

% Change the color of the right y-axis tick labels to black
ax = gca;  % Get the current axes
ax.YAxis(2).Color = 'k';  % Set the y-axis tick labels color to black

% Add additional plots and labels
hold on
yyaxis left
plot(xlim, [N N], 'k-')
plot(xlim, [mean(y) mean(y)], 'k--')
xlabel('Bus')
ylabel('# Combinations')

% Create a second y-axis label
ylabel('Number of combinations')

x_padding = 0.05 * (max(x) - min(x));
xlim([min(x) - x_padding, max(x) + x_padding])  % Expand the x-axis limits with padding
xticks(x)  % Set the x-axis ticks to match the x values

% Add title and legend
title('1 bus failure')
grid on
end