data = clusters.all_gm;
figure
counts = 0;
for m = 1:size(data ,3)
    for j = 1:size(data ,2)
        counts = counts + 1;
        for i = 1:size(data ,1)
             aic(i, counts) = data{i,j,m}.AIC;
        end
    end
end

plot(aic, 'LineWidth', 1.5)
title( 'AIC For Various $k$ and $\Sigma$ Choices','Interpreter','latex');
xlabel('$k$','Interpreter','Latex','Interpreter','latex');
ylabel('AIC score');
%ylim(app.UIAxes, [0 1.5*max(reshape(aic,nK,nSigma*nSC), [], "all")])
legend({'Diagonal-shared','Full-shared','Diagonal-unshared',...
    'Full-unshared'})
savefig("AIC")

