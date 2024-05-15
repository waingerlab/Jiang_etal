%% Repeated measures plotter
%data should be cell array where each column is a genotype and each row is
%a timepoint

%for example:
%xpoints = 0.5:0.5:8.5; %these mark the time passed in weeks since day 16
%xlimit = [0 8.5];
%ypoints = [0 .5 1];
%ylimit = [0 1];
%linecolors = {[0 0 0], [1 0 0]};
%shadecolors = {[.5 .5 .5], [.5 0 0]};

%TDP_comp = normsortedforrepeat(:,[2,4]);
%repeatplotter(TDP_comp,xpoints,xlimit,ypoints,ylimit,linecolors,shadecolors)



function graph = repeatplotter_v2(data,xpoints, xlimit, ypoints, ylimit, linecolors, shadecolors);

groupnum = size(data);

average = cellfun(@mean,data);
stdev = cellfun(@std,data);
count = cellfun(@numel,data);
SEM = stdev./sqrt(count);
high = average+SEM;
low = average-SEM;

hold on
for nn=1:groupnum(2)
    for n=1:(groupnum(1)-1)
        f=fill([xpoints(n) xpoints(n) xpoints(n+1) xpoints(n+1)],[high(n,nn),low(n,nn),  low(n+1,nn), high(n+1,nn)],shadecolors{nn},'linestyle','none');
        set(f,'facealpha',.33);
        line([xpoints(n);xpoints(n+1)],[average(n,nn); average(n+1,nn)],'color',linecolors{nn},'LineWidth',2);
        for nnn=1:numel(data{n,nn})
            p=line([xpoints(n);xpoints(n+1)],[data{n,nn}(nnn); data{n+1,nn}(nnn)],'color',shadecolors{nn}*1.5);
            p.Color(4) = .33;
        end
    end
end
xlim(xlimit);
ylim(ylimit);
set(gca,'Xtick',xpoints,'Ytick',ypoints);
hold off

        