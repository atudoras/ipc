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
possibleValues = [1 2 3];
Role_list = combvec(possibleValues,possibleValues,possibleValues,possibleValues,possibleValues,possibleValues)';    
Roles_comb_valid = valid_rolescomb(Role_list,AC_zones_NSG,DC_zones);
Nrc = length(Roles_comb_valid(:,1));
% falla node - 11 nodes
% falla convertidor - 6 convertidors
% falla AC line - 11 linies
% falla ACDC line - 6 linies
% falla DC line - 5 linies
% Total possibles faltes: 11+6+11+6+5 = 39

%faults = list_faults(n,C,AC_lines,ACDC_lines,DC_lines);
faults = list_line_faults(AC_lines,ACDC_lines,DC_lines);
% N - k, 0 < k < 40
[data,id_faults_valid,id_faults_critical,Roles_combs_f, Ns] = ...
    n_faults(1,A,B,D,S,faults,Roles_comb_valid);

kmax = 5;
Critical_Faults = cell(1,kmax); 
Critical_Faults{1} = id_faults_critical;
Converter_Comb_fails = cell(1,kmax);
Converter_Comb_fails_prop = Converter_Comb_fails;
nfails = zeros(1,Nrc);
for kkk=1:Nrc
    rcf = Roles_combs_f{kkk};
    if ~isempty(rcf)
        nfails(kkk) = length(rcf(:,1));
    end
end
Converter_Comb_fails{1} = nfails;
Converter_Comb_fails_prop{1} = nfails./Ns;

for k=2:kmax
    [data, id_faults_valid, id_faults_critical, Roles_combs_f, Ns] = ...
        n_faults_nr(k,A,B,D,S,id_faults_valid,faults,Roles_comb_valid);
    Critical_Faults{k} = id_faults_critical;
    nfails = zeros(1,Nrc);
    for kkk=1:Nrc
        rcf = Roles_combs_f{kkk};
        if ~isempty(rcf)
            nfails(kkk) = length(rcf(:,1));
        end
    end
    % Afegir a l'entrada DGFFDGFA{k} un vector de mida
    % (length(Roles_comb_valid)) on cada entrada sigui la length de
    % Roles_comb_f{k}
    Converter_Comb_fails{k} = nfails;
    Converter_Comb_fails_prop{k} = nfails./Ns;
end

% Iterate over each element of the cell array
for i = 1:kmax
    fprintf('---------\n k = %d\n---------\n',i)
    % Extract the rows corresponding to the indices in the double array
    indices = Critical_Faults{i};
    for j = 1:length(indices(:,1))
        indexs = indices(j,:);
        % Extract the rows from the table
        faultTable = faults(indexs,1:2);
        
        % Display the information for the current element
        fprintf('Combination %d:\n', j);
        disp(faultTable);
        
        fprintf('\n'); % Add a new line for separation
    end
end

%% quantify
ConvRoles_Fails = zeros(Nrc,kmax);
ConvRoles_Fails_pr = zeros(Nrc,kmax);
Resistantcombs = cell(1,kmax);
n_resistantcombs = zeros(1,kmax);
for k=1:kmax
    convfails = Converter_Comb_fails{k};
    ConvRoles_Fails(:,k) = convfails;
    ConvRoles_Fails_pr(:,k) = Converter_Comb_fails_prop{k};
    ind = find(convfails==0);
    Resistantcombs{k} = ind;
    n_resistantcombs(k) = length(ind);
end
writematrix(ConvRoles_Fails,'ConvRoles_Fails.csv');
writematrix(ConvRoles_Fails_pr,'ConvRoles_Fails_pr.csv');

heatmap(ConvRoles_Fails_pr(1:95,:))
xlabel('Number of faults')
ylabel('Converter Role Combination')
title('Proportion of times the system does not work')

figure(22)
plot(1:kmax,n_resistantcombs)
xlabel('Number of faults')
ylabel('Number of resistant combinations')

%% class

Nums = zeros(6,6); %0,1,2,3,4,5
OneFail = zeros(6,6); 
TwoFail = zeros(6,6); 
ThreeFail = zeros(6,6);
FourFail = zeros(6,6);
FiveFail = zeros(6,6);
for n = 1:95
    role = Roles_comb_valid(n,:);
    nAC = length(find(role==1))+1; %Xlabel
    nDC = length(find(role==2))+1; %Ylabel
    Nums(nDC,nAC) = Nums(nDC,nAC)+1; % primer --> fila // segon --> columna
    props = ConvRoles_Fails_pr(n,:);
    OneFail(nDC,nAC) = OneFail(nDC,nAC) + props(1);
    TwoFail(nDC,nAC) = TwoFail(nDC,nAC) + props(2);
    ThreeFail(nDC,nAC) = ThreeFail(nDC,nAC) + props(3);
    FourFail(nDC,nAC) = FourFail(nDC,nAC) + props(4);
    FiveFail(nDC,nAC) = FiveFail(nDC,nAC) + props(5);
end

OneFail = OneFail./max(Nums,1); OneFail(find(OneFail==0)) = NaN;
TwoFail = TwoFail./max(Nums,1); TwoFail(find(TwoFail==0)) = NaN;
ThreeFail = ThreeFail./max(Nums,1); ThreeFail(find(ThreeFail==0)) = NaN;
FourFail = FourFail./max(Nums,1); FourFail(find(FourFail==0)) = NaN;
FiveFail = FiveFail./max(Nums,1); FiveFail(find(FiveFail==0)) = NaN;

figure(41)
h = heatmap(OneFail(3:5,2:5));
ax = gca;
ax.XData = ["1" "2" "3" "4"];
ax.YData = ["2" "3" "4"];
xlabel('#AC-GFM')
ylabel('#DC-GFM')
title('Proportion of times the system does not work with 1 incidence')
print(gcf,'1fail.png','-dpng','-r600');

figure(42)
h = heatmap(TwoFail(3:5,2:5));
ax = gca;
ax.XData = ["1" "2" "3" "4"];
ax.YData = ["2" "3" "4"];
xlabel('#AC-GFM')
ylabel('#DC-GFM')
title('Average proportion of times the system does not work with 2 incidences')
print(gcf,'2fails.png','-dpng','-r600');


figure(43)
h = heatmap(ThreeFail(3:5,2:5));
ax = gca;
ax.XData = ["1" "2" "3" "4"];
ax.YData = ["2" "3" "4"];
xlabel('#AC-GFM')
ylabel('#DC-GFM')
title('Average proportion of times the system does not work with 3 incidences')
print(gcf,'3fails.png','-dpng','-r600');


figure(44)
h = heatmap(FourFail(3:5,2:5));
ax = gca;
ax.XData = ["1" "2" "3" "4"];
ax.YData = ["2" "3" "4"];
xlabel('#AC-GFM')
ylabel('#DC-GFM')
title('Average proportion of times the system does not work with 4 incidences')
print(gcf,'4fails.png','-dpng','-r600');


figure(45)
h = heatmap(FiveFail(3:5,2:5));
ax = gca;
ax.XData = ["1" "2" "3" "4"];
ax.YData = ["2" "3" "4"];
xlabel('#AC-GFM')
ylabel('#DC-GFM')
title('Average proportion of times the system does not work with 5 incidences')
print(gcf,'5fails.png','-dpng','-r600');
