% AC adjacency matrix between buses
n = 11;
AC_lines = {[1 2],[2 4],[4 5],[1 3],[3 4],[3 5],[6 7],[7 8],[8 9],[6 9],[10 11]};
A = adj_mat(AC_lines,n);

% Incidence matrix from converters to buses
C = 6;
ACDC_lines = {[1 2],[2 4],[3 6],[4 5],[5 10],[6 9]};
B = inc_mat_conv_bus(ACDC_lines,n,C);

% Buses connected to synchronous generators
S = [1 8];
% DC Adjacency matrix between converters
DC_lines = {[1 3],[2 3],[4 6],[5 6],[4 5]};
D = adj_mat(DC_lines,C);

%% AC zones
AC_zones_NSG = AC_zones(A,B,S);

%% DC zones
DC_zones = connected_components(D);

%% Number of possible role assignments
C=length(D); 
N = num_valid_comb(C,AC_zones_NSG,DC_zones);
proportion = N/(3^C);

%% 1 bus fails
y = zeros(1,n);
for k=1:n
    [Anew,Bnew] = fail_bus(k,A,B);
    ACz_new = AC_zones(Anew,Bnew,S);
    y(k) = num_valid_comb(C,ACz_new,DC_zones);
end

x = 1:n;

figure(1)
bar(x,y,0.6)
hold on
plot(xlim,[N N], 'k-')
plot(xlim,[mean(y) mean(y)], 'k--')
xlabel('Bus')
%ylabel('Number of combinations')
title('Number of combinations')
subtitle('1 bus failure')

%% 1 Converter fails
y = zeros(1,C);
for k=1:C
    [Bnew,Dnew] = fail_converter(k,B,D);
    ACz_new = AC_zones(A,Bnew,S);
    DCz_new = connected_components(Dnew);
    y(k) = num_valid_comb(C,ACz_new,DCz_new);
end

x = 1:C;

figure(2)
bar(x,y,0.6)
hold on
plot(xlim,[N N], 'k-')
plot(xlim,[mean(y) mean(y)], 'k--')
xlabel('Converter')
%ylabel('Number of combinations')
title('Number of combinations')
subtitle('1 converter failure')

%% 1 AC line fails
y = zeros(1,length(AC_lines));
xLabels = cell(1,length(AC_lines));
for k=1:length(AC_lines)
    line = AC_lines{k};
    Anew = fail_AC_line(line(1),line(2),A);
    ACz_new = AC_zones(Anew,B,S);
    y(k) = num_valid_comb(C,ACz_new,DC_zones);
    xLabels{k} = sprintf('[%d %d]',line(1),line(2));
end

% Create bar plot
figure(3)
bar(y);
hold on
plot(xlim,[N N], 'k-')
plot(xlim,[mean(y) mean(y)], 'k--')

% Customize x-axis tick labels
xticks(1:length(y)); % Set tick positions
xticklabels(xLabels); % Set tick labels

% Add x-axis label and legend
xlabel('AC Line')
title('Number of combinations')
subtitle('1 AC line failure')

%% 1 bus-converter line fault
y = zeros(1,length(ACDC_lines));
xLabels = cell(1,length(ACDC_lines));
for k=1:length(ACDC_lines)
    line = ACDC_lines{k};
    Bnew = fail_DC_conv_bus(line(1),line(2),B);
    ACz_new = AC_zones(A,Bnew,S);
    y(k) = num_valid_comb(C,ACz_new,DC_zones);
    xLabels{k} = sprintf('[%d %d]',line(1),line(2));
end

% Create bar plot
figure(4)
bar(y);
hold on
plot(xlim,[N N], 'k-')
plot(xlim,[mean(y) mean(y)], 'k--')

% Customize x-axis tick labels
xticks(1:length(y)); % Set tick positions
xticklabels(xLabels); % Set tick labels

% Add x-axis label and legend
xlabel('Converter-Bus Line')
title('Number of combinations')
subtitle('1 converter-bus line failure')

%% 1 DC line failure
y = zeros(1,length(DC_lines));
xLabels = cell(1,length(DC_lines));
for k=1:length(DC_lines)
    line = DC_lines{k};
    Dnew = fail_DC_line(line(1),line(2),D);
    DCz_new = connected_components(Dnew);
    y(k) = num_valid_comb(C,AC_zones_NSG,DCz_new);
    xLabels{k} = sprintf('[%d %d]',line(1),line(2));
end

% Create bar plot
figure(5)
bar(y);
hold on
plot(xlim,[N N], 'k-')
plot(xlim,[mean(y) mean(y)], 'k--')

% Customize x-axis tick labels
xticks(1:length(y)); % Set tick positions
xticklabels(xLabels); % Set tick labels

% Add x-axis label and legend
xlabel('DC Line')
title('Number of combinations')
subtitle('1 DC line failure')

%% 2 buses fail
y = [];
k=1;
for i=1:n-1
    for j=i+1:n
        [Anew,Bnew] = fail_bus(i,A,B);
        [Anew,Bnew] = fail_bus(j,Anew,Bnew);
        ACz_new = AC_zones(Anew,Bnew,S);
        y(k) = num_valid_comb(C,ACz_new,DC_zones);
        xLabels{k} = sprintf('[%d,%d]',i,j);
        k = k+1;
    end
end

% Create bar plot
figure(6)
bar(y);
hold on
plot(xlim,[N N], 'k-')
plot(xlim,[mean(y) mean(y)], 'k--')
%legend('','No failures','Average','Location','best')

% Customize x-axis tick labels
xticks(1:length(y)); % Set tick positions
xticklabels(xLabels); % Set tick labels
set(gca, 'XTickLabelRotation', 90);
% Add x-axis label and legend
xlabel('Pair of buses')
title('Number of combinations')
subtitle('2 buses failure')

%% 2 converters fail
y = [];
k=1;
for i=1:C-1
    for j=i+1:C
        [Bnew,Dnew] = fail_converter(i,B,D);
        [Bnew,Dnew] = fail_converter(j,Bnew,Dnew);
        ACz_new = AC_zones(A,Bnew,S);
        DCz_new = connected_components(Dnew);
        y(k) = num_valid_comb(C,ACz_new,DCz_new);
        xLabels{k} = sprintf('[%d,%d]',i,j);
        k = k+1;
    end
end

% Create bar plot
figure(7)
bar(y);
hold on
plot(xlim,[N N], 'k-')
plot(xlim,[mean(y) mean(y)], 'k--')
%legend('','No failures','Average','Location','best')

% Customize x-axis tick labels
xticks(1:length(y)); % Set tick positions
xticklabels(xLabels); % Set tick labels
set(gca, 'XTickLabelRotation', 90);
% Add x-axis label and legend
xlabel('Pair of converters')
title('Number of combinations')
subtitle('2 converters failure')

%% 2 AC lines fail
y = [];
nl = length(AC_lines);
k=1;
for i=1:nl-1
    for j=i+1:nl
        line1 = AC_lines{i};
        Anew = fail_AC_line(line1(1),line1(2),A);
        line2 = AC_lines{j};
        Anew = fail_AC_line(line2(1),line2(2),Anew);
        ACz_new = AC_zones(Anew,B,S);
        y(k) = num_valid_comb(C,ACz_new,DC_zones);
        xLabels{k} = sprintf('[%d,%d],[%d,%d]',line1(1),line1(2),...
            line2(1),line2(2));
        k = k+1;
    end
end


% Create bar plot
figure(8)
bar(y);
hold on
plot(xlim,[N N], 'k-')
plot(xlim,[mean(y) mean(y)], 'k--')

% Customize x-axis tick labels
xticks(1:length(y)); % Set tick positions
xticklabels(xLabels); % Set tick labels

% Add x-axis label and legend
xlabel('AC Line Pair')
title('Number of combinations')
subtitle('2 AC lines failure')