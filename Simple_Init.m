function [WORLD, agents, tasks, P] = Simple_Init(N, M, seed)
% -------------------------------------------------------------
% 아주 단순화된 초기화
%  - WORLD: 좌표/팔레트
%  - agents: 위치, 속도, 연료계수
%  - tasks : 위치, 보상(value), 시간창(start~end), duration
%  - P     : 파라미터(용량 Lt 등)
% -------------------------------------------------------------
if nargin < 3, seed = 1; end
rng(seed);

% 월드/색상
WORLD.XMIN=-2; WORLD.XMAX= 2.5;
WORLD.YMIN=-1.5; WORLD.YMAX= 5.5;
WORLD.ZMIN= 0;   WORLD.ZMAX= 2;
WORLD.CMAP = lines(max(N,M));

% 파라미터
P.N  = N;            % #agents
P.M  = M;            % #tasks
P.Lt = 3;            % capacity per agent (bundle max length)
P.vel = 2;           % 모든 agent 동일 정속
P.fuel = 0.5;        % 이동 1단위당 비용 계수
P.maxIter = 30;      % 반복 제한
P.eps = 1e-9;        % tie-break용

% 에이전트 생성
for a = 1:N
    agents(a).id   = a;
    agents(a).x    = WORLD.XMIN + (WORLD.XMAX-WORLD.XMIN)*rand;
    agents(a).y    = WORLD.YMIN + (WORLD.YMAX-WORLD.YMIN)*rand;
    agents(a).vel  = P.vel;
    agents(a).fuel = P.fuel;
end

% 태스크 생성 (TRACK/RESCUE 같은 타입 없이 심플)
for j = 1:M
    tasks(j).id       = j;
    tasks(j).x        = WORLD.XMIN + (WORLD.XMAX-WORLD.XMIN)*rand;
    tasks(j).y        = WORLD.YMIN + (WORLD.YMAX-WORLD.YMIN)*rand;
    tasks(j).value    = 100*(0.7+0.3*rand);  % 70~100 보상
    tasks(j).duration = randi([5,15]);       % 5~15초
    tasks(j).start    = 10*rand;             % 0~10
    tasks(j).end      = tasks(j).start + tasks(j).duration; % 간단화
end
end
