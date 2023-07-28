% AC adjacency matrix between buses
n = 11;
AC_lines = {[1 2],[2 4],[4 5],[1 3],[3 4],[3 5],[6 7],[7 8],[8 9],[6 9],[10 11]};
A = adj_mat(AC_lines,n);

% Incidence matrix from converters --> buses
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
N_out = zeros(1,n);
for k=1:n
    % a) Aplicar falta
    [Anew,Bnew] = fail_bus(k,A,B);
    Dnew = D;
    % b) Mirar quants nodes es queden fora de la xarxa amb slack
    %    i eliminar-los fent que totes les seves connexions siguin zero
    [n_out,Anew,Bnew,Dnew] = invalid_nodes(Anew,Bnew,Dnew,S,n,k);
    N_out(k) = n_out-1;
    % c) Redefinir noves zones de la xarxa
    ACz_new = AC_zones(Anew,Bnew,S);
    % d) Calcular el nombre de combinacions possibles
    y(k) = num_valid_comb(C,ACz_new,DC_zones);
end

x = 1:n;
data_1busf = table(x', y', N_out', 'VariableNames', {'Bus', 'Combinations', 'Lost Buses'});
% Save the data to Excel
writetable(data_1busf, 'data_1busf.csv');

figure(1)
plot_result_failnode(x,y,N_out,N)
%print(gcf, 'data_1busf','-dpng','-r600');

%% 1 Converter fails
y = zeros(1,C);
N_out = zeros(1,C);
for k=1:C
    [Bnew,Dnew] = fail_converter(k,B,D);
    Anew = A;
    [n_out,Anew,Bnew,Dnew] = invalid_nodes(Anew,Bnew,Dnew,S,n);
    N_out(k) = n_out;
    ACz_new = AC_zones(Anew,Bnew,S);
    DCz_new = connected_components(Dnew);
    y(k) = num_valid_comb(C,ACz_new,DCz_new);
end

x = 1:C;
data_1convf = table(x', y', N_out', 'VariableNames', {'Converter', 'Combinations', 'Lost Buses'});
% Save the data to Excel
writetable(data_1convf, 'data_1convf.csv');

figure(2)
plot_result_failconv(x,y,N_out,N)
%print(gcf, 'data_1convf', '-dpng', '-r600');
% bar(x,y,0.6)
% hold on
% plot(xlim,[N N], 'k-')
% plot(xlim,[mean(y) mean(y)], 'k--')
% xlabel('Converter')
% %ylabel('Number of combinations')
% title('Number of combinations')
% subtitle('1 converter failure')

%% 1 AC line fails
y = zeros(1,length(AC_lines));
N_out = zeros(1,length(AC_lines));
xLabels = cell(1,length(AC_lines));
for k=1:length(AC_lines)
    line = AC_lines{k};
    Anew = fail_AC_line(line(1),line(2),A);
    Bnew = B;
    Dnew = D;
    [n_out,Anew,Bnew,Dnew] = invalid_nodes(Anew,Bnew,Dnew,S,n);
    N_out(k) = n_out;
    ACz_new = AC_zones(Anew,B,S);
    y(k) = num_valid_comb(C,ACz_new,DC_zones);
    xLabels{k} = sprintf('[%d %d]',line(1),line(2));
    
end

data_1linef = table(xLabels', y', N_out', 'VariableNames', {'Line', 'Combinations', 'Lost Buses'});
% Save the data to Excel
writetable(data_1linef, 'data_1linef.csv');

% Create bar plot
figure(3)
x = 1:length(AC_lines);
plot_result_failline(x,y,N_out,N,xLabels)
%print(gcf, 'data_1linef', '-dpng', '-r600');
% bar(y);
% hold on
% plot(xlim,[N N], 'k-')
% plot(xlim,[mean(y) mean(y)], 'k--')
% 
% % Customize x-axis tick labels
% xticks(1:length(y)); % Set tick positions
% xticklabels(xLabels); % Set tick labels
% 
% % Add x-axis label and legend
% xlabel('AC Line')
% title('Number of combinations')
% subtitle('1 AC line failure')

%% 1 bus-converter line fault
y = zeros(1,length(ACDC_lines));
N_out = y;
Conv_L = y;
Bus_L = y;

xLabels = cell(1,length(ACDC_lines));
for k=1:length(ACDC_lines)
    line = ACDC_lines{k};
    Bnew = fail_DC_conv_bus(line(1),line(2),B);
    Anew=A;
    Dnew=D;
    [n_out,Anew,Bnew,Dnew] = invalid_nodes(Anew,Bnew,Dnew,S,n);
    N_out(k) = n_out;
    ACz_new = AC_zones(A,Bnew,S);
    y(k) = num_valid_comb(C,ACz_new,DC_zones);
    xLabels{k} = sprintf('[%d %d]',line(1),line(2));
    Conv_L(k) = line(1);
    Bus_L(k) = line(2);
end

% Create bar plot
x = 1:length(ACDC_lines);

data_1acdclinef = table(Conv_L',Bus_L', y', N_out', 'VariableNames', {'Converter', 'Bus','Combinations', 'Lost Buses'});
% Save the data to Excel
writetable(data_1acdclinef, 'data_1acdclinef.csv');


figure(4)
plot_result_failline(x,y,N_out,N,xLabels)

% bar(y);
% hold on
% plot(xlim,[N N], 'k-')
% plot(xlim,[mean(y) mean(y)], 'k--')
% 
% % Customize x-axis tick labels
% xticks(1:length(y)); % Set tick positions
% xticklabels(xLabels); % Set tick labels

% Add x-axis label and legend
xlabel('Converter-Bus Line')
title('1 converter-bus line failure')
%print(gcf, 'data_1acdclinef', '-dpng', '-r600');


%% 1 DC line failure
y = zeros(1,length(DC_lines));
N_out = y;

xLabels = cell(1,length(DC_lines));
for k=1:length(DC_lines)
    line = DC_lines{k};
    Dnew = fail_DC_line(line(1),line(2),D);
    Anew=A;
    Bnew=B;
    [n_out,Anew,Bnew,Dnew] = invalid_nodes(Anew,Bnew,Dnew,S,n);
    N_out(k) = n_out;
    DCz_new = connected_components(Dnew);
    y(k) = num_valid_comb(C,AC_zones_NSG,DCz_new);
    xLabels{k} = sprintf('[%d %d]',line(1),line(2));
end

% Create bar plot
x = 1:length(DC_lines);
data_1dclinef = table(xLabels', y', N_out', 'VariableNames', {'Line', 'Combinations', 'Lost Buses'});
% Save the data to Excel
writetable(data_1dclinef, 'data_1dclinef.csv');

figure(5)
plot_result_failline(x,y,N_out,N,xLabels)

% bar(y);
% hold on
% plot(xlim,[N N], 'k-')
% plot(xlim,[mean(y) mean(y)], 'k--')
% 
% % Customize x-axis tick labels
% xticks(1:length(y)); % Set tick positions
% xticklabels(xLabels); % Set tick labels

% Add x-axis label and legend
xlabel('DC Line')
title('1 DC line failure')
% print(gcf, 'data_1dclinef', '-dpng', '-r600');
% %% 2 buses fail
% y = [];
% k=1;
% for i=1:n-1
%     for j=i+1:n
%         [Anew,Bnew] = fail_bus(i,A,B);
%         [Anew,Bnew] = fail_bus(j,Anew,Bnew);
%         ACz_new = AC_zones(Anew,Bnew,S);
%         y(k) = num_valid_comb(C,ACz_new,DC_zones);
%         xLabels{k} = sprintf('[%d,%d]',i,j);
%         k = k+1;
%     end
% end
% 
% % Create bar plot
% figure(6)
% bar(y);
% hold on
% plot(xlim,[N N], 'k-')
% plot(xlim,[mean(y) mean(y)], 'k--')
% %legend('','No failures','Average','Location','best')
% 
% % Customize x-axis tick labels
% xticks(1:length(y)); % Set tick positions
% xticklabels(xLabels); % Set tick labels
% set(gca, 'XTickLabelRotation', 90);
% % Add x-axis label and legend
% xlabel('Pair of buses')
% title('Number of combinations')
% subtitle('2 buses failure')
% 
% %% 2 converters fail
% y = [];
% k=1;
% for i=1:C-1
%     for j=i+1:C
%         [Bnew,Dnew] = fail_converter(i,B,D);
%         [Bnew,Dnew] = fail_converter(j,Bnew,Dnew);
%         ACz_new = AC_zones(A,Bnew,S);
%         DCz_new = connected_components(Dnew);
%         y(k) = num_valid_comb(C,ACz_new,DCz_new);
%         xLabels{k} = sprintf('[%d,%d]',i,j);
%         k = k+1;
%     end
% end
% 
% % Create bar plot
% figure(7)
% bar(y);
% hold on
% plot(xlim,[N N], 'k-')
% plot(xlim,[mean(y) mean(y)], 'k--')
% %legend('','No failures','Average','Location','best')
% 
% % Customize x-axis tick labels
% xticks(1:length(y)); % Set tick positions
% xticklabels(xLabels); % Set tick labels
% set(gca, 'XTickLabelRotation', 90);
% % Add x-axis label and legend
% xlabel('Pair of converters')
% title('Number of combinations')
% subtitle('2 converters failure')
% 
%% 2 AC lines fail

nl = length(AC_lines);
y = zeros(1,nchoosek(nl,2));
N_out = y;
k=1;
xLabels = cell(1,nchoosek(nl,2));
xLabels_1 = xLabels; 
xLabels_2 = xLabels; 
for i=1:nl-1
    for j=i+1:nl
        line1 = AC_lines{i};
        Anew = fail_AC_line(line1(1),line1(2),A);
        line2 = AC_lines{j};
        Anew = fail_AC_line(line2(1),line2(2),Anew);
        Bnew = B; Dnew = D;
        [n_out,Anew,Bnew,Dnew] = invalid_nodes(Anew,Bnew,Dnew,S,n);
        N_out(k) = n_out;
        ACz_new = AC_zones(Anew,B,S);
        y(k) = num_valid_comb(C,ACz_new,DC_zones);
        xLabels{k} = sprintf('[%d,%d],[%d,%d]',line1(1),line1(2),...
            line2(1),line2(2));
        xLabels_1{k} = sprintf('[%d %d]',line1(1),line1(2));
        xLabels_2{k} = sprintf('[%d %d]',line2(1),line2(2));
        k = k+1;
    end
end

ind1 = find(y ~= N);
ind2 = find(N_out > 0);
Ny = length(y);
x = 1:length(y);
data_2AClinesf = table(xLabels', y', N_out', 'VariableNames', {'AC Lines', 'Combinations', 'Lost Buses'});
writetable(data_2AClinesf, 'data_2AClinesf.csv');
indx = unique([ind1 ind2]);
data_2AClinesf_rel = table(xLabels_1(indx)', xLabels_2(indx)', y(indx)',...
    N_out(indx)', 'VariableNames', {'Line 1', 'Line 2','Combinations', 'Lost Buses'});
writetable(data_2AClinesf_rel, 'data_2AClinesf_rel.csv');

% Create bar plot
figure(8)
%plot_result_failline(x,y,N_out,N,xLabels)
bar(y);
hold on
plot(xlim,[N N], 'k-')
plot(xlim,[mean(y) mean(y)], 'k--')

% Customize x-axis tick labels
xticks(1:length(y)); % Set tick positions
xticklabels(xLabels); % Set tick labels

% % Add x-axis label and legend
xlabel('AC Line Pair')
ylabel('Number of combinations')
title('2 AC lines failure')
grid on

figure(9)
%plot_result_failline(x,y,N_out,N,xLabels)
bar(y(ind1));
hold on
plot(xlim,[N N], 'k-')
plot(xlim,[mean(y) mean(y)], 'k--')

% Customize x-axis tick labels
xticks(1:length(y(ind1))); % Set tick positions
xticklabels(xLabels(ind1)); % Set tick labels

% % Add x-axis label and legend
xlabel('AC Line Pair')
ylabel('Number of combinations')
title('2 AC lines failure')
grid on

figure(10)
%plot_result_failline(x,y,N_out,N,xLabels)
bar(N_out,'FaceColor','#B22222');
grid on
% Customize x-axis tick labels
xticks(1:length(y)); % Set tick positions
xticklabels(xLabels); % Set tick labels
yticks_right = unique([N_out 1:max(N_out)]);
yticks_right = yticks_right(rem(yticks_right, 1) == 0);  % Keep only the integer values
yticks(yticks_right);
% % Add x-axis label and legend
xlabel('AC Line Pair')
ylabel('Additional lost buses')
title('2 AC lines failure')

%% 3 AC lines fail

nl = length(AC_lines);
y = zeros(1,nchoosek(nl,3));
N_out = y;
k=1;
xLabels = cell(1,nchoosek(nl,3));
xLabels_1 = xLabels; 
xLabels_2 = xLabels; 
xLabels_3 = xLabels; 
for i=1:nl-2
    for j=i+1:nl-1
        for kk=j+1:nl
            line1 = AC_lines{i};
            Anew = fail_AC_line(line1(1),line1(2),A);
            line2 = AC_lines{j};
            Anew = fail_AC_line(line2(1),line2(2),Anew);
            line3 = AC_lines{kk};
            Anew = fail_AC_line(line3(1),line3(2),Anew);
            Bnew = B; Dnew = D;
            [n_out,Anew,Bnew,Dnew] = invalid_nodes(Anew,Bnew,Dnew,S,n);
            N_out(k) = n_out;
            ACz_new = AC_zones(Anew,B,S);
            y(k) = num_valid_comb(C,ACz_new,DC_zones);
            xLabels{k} = sprintf('[%d,%d],[%d,%d],[%d,%d]',line1(1),...
                line1(2),line2(1),line2(2),line3(1),line3(2));
            xLabels_1{k} = sprintf('[%d %d]',line1(1),line1(2));
            xLabels_2{k} = sprintf('[%d %d]',line2(1),line2(2));
            xLabels_3{k} = sprintf('[%d %d]',line3(1),line3(2));
            k = k+1;
        end
    end
end

ind1 = find(y ~= N);
ind2 = find(N_out > 0);
Ny = length(y);
x = 1:length(y);
data_3AClinesf = table(xLabels', y', N_out', 'VariableNames', {'AC Lines', 'Combinations', 'Lost Buses'});
writetable(data_3AClinesf, 'data_3AClinesf.csv');
indx = unique([ind1 ind2]);
data_3AClinesf_rel = table(xLabels_1(indx)',...
    xLabels_2(indx)',xLabels_3(indx)',y(indx)',...
    N_out(indx)', 'VariableNames',...
    {'Line 1', 'Line 2', 'Line 3', 'Combinations', 'Lost Buses'});
writetable(data_3AClinesf_rel, 'data_3AClinesf_rel.csv');

% Create bar plot
figure(11)
%plot_result_failline(x,y,N_out,N,xLabels)
bar(y);
hold on
plot(xlim,[N N], 'k-')
plot(xlim,[mean(y) mean(y)], 'k--')

% Customize x-axis tick labels
xticks(1:length(y)); % Set tick positions
xticklabels(xLabels); % Set tick labels

% % Add x-axis label and legend
xlabel('AC Lines')
ylabel('Number of combinations')
title('3 AC lines failure')
grid on

figure(12)
%plot_result_failline(x,y,N_out,N,xLabels)
bar(y(ind1));
hold on
plot(xlim,[N N], 'k-')
plot(xlim,[mean(y) mean(y)], 'k--')

% Customize x-axis tick labels
xticks(1:length(y(ind1))); % Set tick positions
xticklabels(xLabels(ind1)); % Set tick labels

% % Add x-axis label and legend
xlabel('AC Lines')
ylabel('Number of combinations')
title('3 AC lines failure')
grid on

figure(13)
%plot_result_failline(x,y,N_out,N,xLabels)
bar(N_out,'FaceColor','#B22222');
grid on
% Customize x-axis tick labels
xticks(1:length(y)); % Set tick positions
xticklabels(xLabels); % Set tick labels
yticks_right = unique([N_out 1:max(N_out)]);
yticks_right = yticks_right(rem(yticks_right, 1) == 0);  % Keep only the integer values
yticks(yticks_right);
% % Add x-axis label and legend
xlabel('AC Lines')
ylabel('Additional lost buses')
title('3 AC lines failure')