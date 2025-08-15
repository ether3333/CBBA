function Simple_Plot(WORLD, Assign, agents, tasks, figBase)
if nargin<5, figBase=1; end
N = numel(agents); M = numel(tasks);

%% Figure 1: 3D 경로 (X,Y vs Time)
figure(figBase); clf; hold on; grid on
title('Agent Paths with Time Windows'); xlabel X; ylabel Y; zlabel Time
C = WORLD.CMAP;

% Task time window (수직선)
for j=1:M
    plot3(tasks(j).x+[0 0], tasks(j).y+[0 0], [tasks(j).start tasks(j).end], 'k:','LineWidth',1.5);
    text(tasks(j).x, tasks(j).y, tasks(j).start, sprintf('T%d',j));
end

% Agents: 시작점/경로/수행(수직)
for a=1:N
    col = C(a,:);
    plot3(agents(a).x, agents(a).y, 0,'o','MarkerFaceColor',col,'MarkerEdgeColor','k');
    text(agents(a).x, agents(a).y, 0.1, sprintf('A%d',a), 'FontWeight','bold','Color',col,'BackgroundColor','w','Margin',2);

    if isempty(Assign(a).bundle), continue; end
    % 시작→첫 태스크 이동
    j1 = Assign(a).bundle(1);
    plot3([agents(a).x tasks(j1).x],[agents(a).y tasks(j1).y],[0 Assign(a).times(1)],'-','Color',col,'LineWidth',2);
    % 첫 태스크 수행(수직)
    plot3(tasks(j1).x+[0 0],tasks(j1).y+[0 0], [Assign(a).times(1) Assign(a).times(1)+tasks(j1).duration], '-^','Color',col);

    % 이후
    for k=2:numel(Assign(a).bundle)
        jPrev = Assign(a).bundle(k-1); jCur = Assign(a).bundle(k);
        tPrevEnd = Assign(a).times(k-1) + tasks(jPrev).duration;
        plot3([tasks(jPrev).x tasks(jCur).x],[tasks(jPrev).y tasks(jCur).y],[tPrevEnd Assign(a).times(k)], '-','Color',col,'LineWidth',2);
        plot3(tasks(jCur).x+[0 0],tasks(jCur).y+[0 0], [Assign(a).times(k) Assign(a).times(k)+tasks(jCur).duration], '-^','Color',col);
    end
end
hold off

%% Figure 2: 스케줄 (agent별 가로막대)
figure(figBase+1); clf
tmax = max([tasks.end]); if isempty(tmax), tmax=1; end
for a=1:N
    subplot(N,1,a); hold on; grid on
    ylabel(sprintf('A%d',a), 'FontWeight','bold','Color',C(a,:));
    axis([0 tmax 0 2]);
    for k=1:numel(Assign(a).bundle)
        j = Assign(a).bundle(k);
        t0 = Assign(a).times(k); t1 = t0 + tasks(j).duration;
        plot([t0 t1],[1 1],'-','Color',C(a,:),'LineWidth',10);          % 실제 수행
        plot([tasks(j).start tasks(j).end],[1 1],'k--');                % time window
        text(t0,1.05,sprintf('T%d',j));
    end
    if a==1, title('Agent Schedules'); end
end
xlabel('Time');
end
