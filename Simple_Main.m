% Run_CBBA_Simple.m

% 1. 초기화
[WORLD, agents, tasks, P] = Simple_Init(5, 10, 24377);

% 2. 메인 루프 실행
[Assign, TotalScore] = Simple_Bundle(WORLD, agents, tasks, P);

% 3. 결과 출력
disp('=== Final Assignment ===');
for a = 1:P.N
    fprintf('Agent %d: ', a);
    fprintf('%d ', Assign(a).bundle);
    fprintf('\n');
end
fprintf('Total Score: %.2f\n', TotalScore);

% 4. 시각화
Simple_Plot(WORLD, Assign, agents, tasks, 1);