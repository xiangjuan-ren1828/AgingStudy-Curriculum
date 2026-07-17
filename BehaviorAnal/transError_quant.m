function transError_quant()
% write by XR @ July 16 2026
% A function for quantifying the transition errors or transition accuracy.

slotCorr_con = slotCorr_marg_con;
slotCorr_pos = slotCorr_marg_pos;
transError_con = nan(sum(~reconsOnly), (nTrans - 1));
transError_pos = nan(sum(~reconsOnly), (nTrans - 1));
trlLen_temp = sum(~reconsOnly);

for iTrans = 1 : (nTrans - 1)
    % ----Content----
    iTrans_from_con = slotCorr_con(:, iTrans);
    iTrans_to_con   = slotCorr_con(:, iTrans + 1);
    transError_con(find(iTrans_from_con == 1 & iTrans_to_con == 1), iTrans) = 1; % Pr(toY=1 | fromX=1); fully correct
    transError_con(find(iTrans_from_con == 1 & iTrans_to_con == 0), iTrans) = 2; % Pr(toY=0 | fromX=1)
    transError_con(find(iTrans_from_con == 0 & iTrans_to_con == 1), iTrans) = 3; % Pr(toY=1 | fromX=0)
    transError_con(find(iTrans_from_con == 0 & iTrans_to_con == 0), iTrans) = 4; % Pr(toY=0 | fromX=0); fully incorrect

    % ----Position----
    iTrans_from_pos = slotCorr_pos(:, iTrans);
    iTrans_to_pos   = slotCorr_pos(:, iTrans + 1);
    transError_pos(find(iTrans_from_pos == 1 & iTrans_to_pos == 1), iTrans) = 1;
    transError_pos(find(iTrans_from_pos == 1 & iTrans_to_pos == 0), iTrans) = 2;
    transError_pos(find(iTrans_from_pos == 0 & iTrans_to_pos == 1), iTrans) = 3;
    transError_pos(find(iTrans_from_pos == 0 & iTrans_to_pos == 0), iTrans) = 4;

end
%%% ------ Quantify the transition accuracy 1) previous report was correct, 2) previous repprt was incorrect------
transError_con_col = reshape(transError_con, [trlLen_temp * (nTrans - 1), 1]);
transError_loc_col = reshape(transError_pos, [trlLen_temp * (nTrans - 1), 1]);
error_con_len = [length(find(transError_con_col == 1)), length(find(transError_con_col == 2)), ...
                 length(find(transError_con_col == 3)), length(find(transError_con_col == 4))];

error_pos_len = [length(find(transError_loc_col == 1)), length(find(transError_loc_col == 2)), ...
                 length(find(transError_loc_col == 3)), length(find(transError_loc_col == 4))];
%%% ------ First and second half per retrieval test ------
transError_con_firstHalf_col = reshape(transError_con(:, 1:2), [trlLen_temp * 2, 1]);
transError_loc_firstHalf_col = reshape(transError_pos(:, 1:2), [trlLen_temp * 2, 1]);
error_con_firstThree_len = [length(find(transError_con_firstHalf_col == 1)), length(find(transError_con_firstHalf_col == 2)), ...
                            length(find(transError_con_firstHalf_col == 3)), length(find(transError_con_firstHalf_col == 4))];
error_pos_firstThree_len = [length(find(transError_loc_firstHalf_col == 1)), length(find(transError_loc_firstHalf_col == 2)), ...
                            length(find(transError_loc_firstHalf_col == 3)), length(find(transError_loc_firstHalf_col == 4))];
transError_con_secondHalf_col = reshape(transError_con(:, 3:4), [trlLen_temp * 2, 1]);
transError_loc_secondHalf_col = reshape(transError_pos(:, 3:4), [trlLen_temp * 2, 1]);
error_con_secondThree_len = [length(find(transError_con_secondHalf_col == 1)), length(find(transError_con_secondHalf_col == 2)), ...
                             length(find(transError_con_secondHalf_col == 3)), length(find(transError_con_secondHalf_col == 4))];
error_pos_secondThree_len = [length(find(transError_loc_secondHalf_col == 1)), length(find(transError_loc_secondHalf_col == 2)), ...
                             length(find(transError_loc_secondHalf_col == 3)), length(find(transError_loc_secondHalf_col == 4))];

% ---- proportion of correct responses if previous item
% is 1) correctly or 2) incorrectly reported ----
% transAcc_count_marg_subj = nan(subLen, 4, 2); % 4: 4 different counts; 2: item and location
% transAcc_count_join_subj = nan(subLen, 4, 2);

% ---- Item ----
transAcc_count_marg_subj(iSub, :, 1) = error_con_len; % 4: 4 different counts; 2: item and location
transAcc_count_marg_firstHalf_subj(iSub, :, 1)  = error_con_firstThree_len;
transAcc_count_marg_secondHalf_subj(iSub, :, 1) = error_con_secondThree_len;

% ---- Location ----
transAcc_count_marg_subj(iSub, :, 2) = error_pos_len;
transAcc_count_marg_firstHalf_subj(iSub, :, 2)  = error_pos_firstThree_len;
transAcc_count_marg_secondHalf_subj(iSub, :, 2) = error_pos_secondThree_len;