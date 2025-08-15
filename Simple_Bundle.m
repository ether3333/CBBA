function [Assign, TotalScore] = Simple_Bundle(WORLD, agents, tasks, P)
% -------------------------------------------------------------
% Minimal CBBA main:
%  ALG2: Communicate (winner/winnerBid 합의)
%  ALG3: BuildBundle (Remove → ALG1:Add)
%  수렴 체크 후 TotalScore 계산
% -------------------------------------------------------------

N = P.N; M = P.M;

% 상태(에이전트별 지역 정보)
for a=1:N
    Assign(a).agentID    = agents(a).id;
    Assign(a).bundle     = [];              % 확정 태스크 시퀀스
    Assign(a).times      = [];              % 시작시각
    Assign(a).winners    = zeros(1,M);      % 내가 아는 승자
    Assign(a).winnerBids = zeros(1,M);      % 내가 아는 최고입찰
end

% 보조 함수
dist = @(x1,y1,x2,y2) hypot(x2-x1,y2-y1);

% 반복
lastChangeIter = 0;
for t = 1:P.maxIter
    changed = false;

    % ==========================================================
    % ALG2: UPDATE TASK — 통신/합의(심플 규칙)
    %  - 더 큰 bid가 승리, 동점은 agent index 작은 쪽
    % ==========================================================
    for s = 1:N
        for r = 1:N
            if s==r, continue; end
            Assign(r).winnerBids = max(Assign(r).winnerBids, Assign(s).winnerBids);
            % 동점 처리: 승자 인덱스 더 작은 쪽
            for j=1:M
                if abs(Assign(r).winnerBids(j) - Assign(s).winnerBids(j)) <= P.eps
                    if Assign(r).winners(j)==0 || ...
                       (Assign(s).winners(j)>0 && Assign(r).winners(j) > Assign(s).winners(j))
                        Assign(r).winners(j) = Assign(s).winners(j);
                    end
                elseif Assign(r).winnerBids(j) < Assign(s).winnerBids(j)
                    Assign(r).winners(j) = Assign(s).winners(j);
                end
            end
        end
    end

    % ==========================================================
    % ALG3: BUILD BUNDLE — Remove → ALG1:Add
    % ==========================================================
    for a=1:N

        % ---------- Remove: outbid되면 해당 지점부터 꼬리 제거 ----------
        if ~isempty(Assign(a).bundle)
            keepIdx = 0;
            for k = 1:numel(Assign(a).bundle)
                j = Assign(a).bundle(k);
                if Assign(a).winners(j) == a
                    keepIdx = k;
                else
                    keepIdx = k-1;
                    break;
                end
            end
            if keepIdx < numel(Assign(a).bundle)
                Assign(a).bundle = Assign(a).bundle(1:keepIdx);
                Assign(a).times  = Assign(a).times(1:keepIdx);
                changed = true;
            end
        end

        % ---------- ALG1: SELECT TASK (단순 점수에 의한 argmax) ----------
        while numel(Assign(a).bundle) < P.Lt
            % 후보: 아직 누구에게도 안 간 태스크(지역 관점)
            taken = [];
            for u=1:N, taken = [taken Assign(u).bundle]; end %#ok<AGROW>
            candidates = setdiff(1:M, unique(taken));
            if isempty(candidates), break; end

            % 현재 위치 (시작점 또는 마지막 태스크 위치)
            if isempty(Assign(a).bundle)
                xa = agents(a).x; ya = agents(a).y; tprev = 0; dur_prev=0;
            else
                lastTask = tasks(Assign(a).bundle(end));
                xa = lastTask.x; ya = lastTask.y;
                tprev = Assign(a).times(end);
                dur_prev = lastTask.duration;
            end

            % 각 후보에 대한 이동/시작시각/입찰 계산
            bids = -inf(1,numel(candidates));
            for c = 1:numel(candidates)
                j = candidates(c);
                travel = dist(xa,ya,tasks(j).x,tasks(j).y) / agents(a).vel;
                t_arr  = tprev + dur_prev + travel;
                t_start= max(tasks(j).start, t_arr);
                feasible = t_start <= (tasks(j).end - tasks(j).duration);
                if feasible
                    % 입찰 = 보상 - 이동비용(연료*거리) - 대기패널티(간단히 0 처리)
                    bid = tasks(j).value - agents(a).fuel*dist(xa,ya,tasks(j).x,tasks(j).y);
                    bids(c) = bid;
                end
            end

            [bestBid, idx] = max(bids);
            if ~isfinite(bestBid), break; end  % 더 넣을 수 없음(모든 후보 infeasible)

            jstar = candidates(idx);

            % 번들/시간 갱신 (맨 뒤에 추가; ⊕ 대신 append)
            travel = dist(xa,ya,tasks(jstar).x,tasks(jstar).y) / agents(a).vel;
            t_arr  = tprev + dur_prev + travel;
            t_start= max(tasks(jstar).start, t_arr);

            Assign(a).bundle(end+1) = jstar;
            Assign(a).times(end+1)  = t_start;

            % winner 정보(지역) 업데이트
            Assign(a).winners(jstar)    = a;
            Assign(a).winnerBids(jstar) = bestBid;

            changed = true;
        end
    end

    % 수렴 체크: 최근 변화 없으면 중단
    if changed
        lastChangeIter = t;
    elseif t - lastChangeIter > 2
        break;
    end
end

% 총점 계산(확정 번들 기준)
TotalScore = 0;
for a=1:N
    for k=1:numel(Assign(a).bundle)
        j = Assign(a).bundle(k);
        % 실제 얻는 점수 = value - 이동비용 (도식적)
        if k==1
            dd = dist(agents(a).x,agents(a).y,tasks(j).x,tasks(j).y);
        else
            prev = tasks(Assign(a).bundle(k-1));
            dd = dist(prev.x,prev.y,tasks(j).x,tasks(j).y);
        end
        TotalScore = TotalScore + tasks(j).value - agents(a).fuel*dd;
    end
end
end
