@echo off

SET WORKDIR=path_to_your_dir\CodeT5
SET PYTHONPATH=%WORKDIR%
SET %WORKDIR%TASK=%~1
SET %WORKDIR%%~1SUB_TASK=%~2
SET %WORKDIR%%~1%~2MODEL_TAG=%~3
SET %WORKDIR%%~1%~2%~3GPU=%~4
SET %WORKDIR%%~1%~2%~3%~4DATA_NUM=%~5
SET %WORKDIR%%~1%~2%~3%~4%~5BS=%~6
SET %WORKDIR%%~1%~2%~3%~4%~5%~6LR=%~7
SET %WORKDIR%%~1%~2%~3%~4%~5%~6%~7SRC_LEN=%~8
SET %WORKDIR%%~1%~2%~3%~4%~5%~6%~7%~8TRG_LEN=%~9
SET %WORKDIR%%~1%~2%~3%~4%~5%~6%~7%~8%~9PATIENCE=%~10
SET %WORKDIR%%~1%~2%~3%~4%~5%~6%~7%~8%~9%~10EPOCH=%~11
SET %WORKDIR%%~1%~2%~3%~4%~5%~6%~7%~8%~9%~10%~11WARMUP=%~12
SET %WORKDIR%%~1%~2%~3%~4%~5%~6%~7%~8%~9%~10%~11%~12MODEL_DIR=%~13
SET %WORKDIR%%~1%~2%~3%~4%~5%~6%~7%~8%~9%~10%~11%~12%~13SUMMARY_DIR=%~14
SET %WORKDIR%%~1%~2%~3%~4%~5%~6%~7%~8%~9%~10%~11%~12%~13%~14RES_FN=%~15
IF [[ %DATA_NUM% == -1 ]] (
  SET DATA_TAG=all
) ELSE (
  SET DATA_TAG=%DATA_NUM%
  SET EPOCH=1
)
IF [[ %TASK% == multi_task ]] (
  SET FULL_MODEL_TAG=%MODEL_TAG%_%DATA_TAG%_lr%LR%_s%~16
) ELSE (
  SET FULL_MODEL_TAG=%MODEL_TAG%_%DATA_TAG%_lr%LR%_bs%BS%_src%SRC_LEN%_trg%TRG_LEN%_pat%PATIENCE%_e%EPOCH%
)
IF [[ %SUB_TASK% == none ]] (
  SET OUTPUT_DIR=%MODEL_DIR%/%TASK%/%FULL_MODEL_TAG%
) ELSE (
  SET OUTPUT_DIR=%MODEL_DIR%/%TASK%/%SUB_TASK%/%FULL_MODEL_TAG%
)
SET %MODEL_DIR%%TASK%%SUB_TASK%%FULL_MODEL_TAG%CACHE_DIR=%OUTPUT_DIR%\cache_data
SET %MODEL_DIR%%TASK%%SUB_TASK%%FULL_MODEL_TAG%%OUTPUT_DIR%RES_DIR=%OUTPUT_DIR%\prediction
SET %MODEL_DIR%%TASK%%SUB_TASK%%FULL_MODEL_TAG%%OUTPUT_DIR%%OUTPUT_DIR%LOG=%OUTPUT_DIR%\train.log
mkdir OUTPUT_DIR
mkdir CACHE_DIR
mkdir RES_DIR
IF [[ %MODEL_TAG% == roberta ]] (
  SET MODEL_TYPE=roberta
  SET TOKENIZER=roberta-base
  SET MODEL_PATH=roberta-base
) ELSE (
  IF [[ %MODEL_TAG% == codebert ]] (
    SET MODEL_TYPE=roberta
    SET TOKENIZER=roberta-base
    SET MODEL_PATH=microsoft\codebert-base
  ) ELSE (
    IF [[ %MODEL_TAG% == bart_base ]] (
      SET MODEL_TYPE=bart
      SET TOKENIZER=facebook\bart-base
      SET MODEL_PATH=facebook\bart-base
    ) ELSE (
      IF [[ %MODEL_TAG% == codet5_small ]] (
        SET MODEL_TYPE=codet5
        SET TOKENIZER=Salesforce\codet5-small
        SET MODEL_PATH=Salesforce\codet5-small
      ) ELSE (
        IF [[ %MODEL_TAG% == codet5_base ]] (
          SET MODEL_TYPE=codet5
          SET TOKENIZER=Salesforce\codet5-base
          SET MODEL_PATH=Salesforce\codet5-base
        )
      )
    )
  )
)
IF [[ %TASK% == multi_task ]] (
  SET RUN_FN=%WORKDIR%\run_multi_gen.py
  SET MULTI_TASK_AUG='--max_steps '%~16' --save_steps '%~17' --log_steps '%~18
) ELSE (
  IF [[ %TASK% == clone ]] (
    SET RUN_FN=%WORKDIR%\run_clone.py
  ) ELSE (
    IF [[ %TASK% == defect ]] && [[ %MODEL_TYPE% == roberta || ${MODEL_TYPE} == bart ]] (
      SET RUN_FN=%WORKDIR%\run_defect.py
    ) ELSE (
      SET RUN_FN=%WORKDIR%\run_gen.py
    )
  )
)
REM UNKNOWN: {"type":"Pipeline","commands":[{"type":"Command","name":{"text":"python","type":"Word"},"prefix":[{"text":"CUDA_VISIBLE_DEVICES=${GPU}","expansion":[{"loc":{"start":-27,"end":-18},"parameter":"WORKDIR","type":"ParameterExpansion"},{"loc":{"start":21,"end":26},"parameter":"GPU","type":"ParameterExpansion"}],"type":"AssignmentWord"}],"suffix":[{"text":"${RUN_FN}","expansion":[{"loc":{"start":0,"end":8},"parameter":"RUN_FN","type":"ParameterExpansion"}],"type":"Word"},{"text":"--do_train","type":"Word"},{"text":"--do_eval","type":"Word"},{"text":"--do_eval_bleu","type":"Word"},{"text":"--do_test","type":"Word"},{"text":"${MULTI_TASK_AUG}","expansion":[{"loc":{"start":0,"end":16},"parameter":"MULTI_TASK_AUG","type":"ParameterExpansion"}],"type":"Word"},{"text":"--task","type":"Word"},{"text":"${TASK}","expansion":[{"loc":{"start":0,"end":6},"parameter":"TASK","type":"ParameterExpansion"}],"type":"Word"},{"text":"--sub_task","type":"Word"},{"text":"${SUB_TASK}","expansion":[{"loc":{"start":0,"end":10},"parameter":"SUB_TASK","type":"ParameterExpansion"}],"type":"Word"},{"text":"--model_type","type":"Word"},{"text":"${MODEL_TYPE}","expansion":[{"loc":{"start":0,"end":12},"parameter":"MODEL_TYPE","type":"ParameterExpansion"}],"type":"Word"},{"text":"--data_num","type":"Word"},{"text":"${DATA_NUM}","expansion":[{"loc":{"start":0,"end":10},"parameter":"DATA_NUM","type":"ParameterExpansion"}],"type":"Word"},{"text":"--num_train_epochs","type":"Word"},{"text":"${EPOCH}","expansion":[{"loc":{"start":0,"end":7},"parameter":"EPOCH","type":"ParameterExpansion"}],"type":"Word"},{"text":"--warmup_steps","type":"Word"},{"text":"${WARMUP}","expansion":[{"loc":{"start":0,"end":8},"parameter":"WARMUP","type":"ParameterExpansion"}],"type":"Word"},{"text":"--learning_rate","type":"Word"},{"text":"${LR}e-5","expansion":[{"loc":{"start":0,"end":4},"parameter":"LR","type":"ParameterExpansion"}],"type":"Word"},{"text":"--patience","type":"Word"},{"text":"${PATIENCE}","expansion":[{"loc":{"start":0,"end":10},"parameter":"PATIENCE","type":"ParameterExpansion"}],"type":"Word"},{"text":"--tokenizer_name=${TOKENIZER}","expansion":[{"loc":{"start":17,"end":28},"parameter":"TOKENIZER","type":"ParameterExpansion"}],"type":"Word"},{"text":"--model_name_or_path=${MODEL_PATH}","expansion":[{"loc":{"start":21,"end":33},"parameter":"MODEL_PATH","type":"ParameterExpansion"}],"type":"Word"},{"text":"--data_dir","type":"Word"},{"text":"${WORKDIR}/data","expansion":[{"loc":{"start":0,"end":9},"parameter":"WORKDIR","type":"ParameterExpansion"}],"type":"Word"},{"text":"--cache_path","type":"Word"},{"text":"${CACHE_DIR}","expansion":[{"loc":{"start":0,"end":11},"parameter":"CACHE_DIR","type":"ParameterExpansion"}],"type":"Word"},{"text":"--output_dir","type":"Word"},{"text":"${OUTPUT_DIR}","expansion":[{"loc":{"start":0,"end":12},"parameter":"OUTPUT_DIR","type":"ParameterExpansion"}],"type":"Word"},{"text":"--summary_dir","type":"Word"},{"text":"${SUMMARY_DIR}","expansion":[{"loc":{"start":0,"end":13},"parameter":"SUMMARY_DIR","type":"ParameterExpansion"}],"type":"Word"},{"text":"--save_last_checkpoints","type":"Word"},{"text":"--always_save_model","type":"Word"},{"text":"--res_dir","type":"Word"},{"text":"${RES_DIR}","expansion":[{"loc":{"start":0,"end":9},"parameter":"RES_DIR","type":"ParameterExpansion"}],"type":"Word"},{"text":"--res_fn","type":"Word"},{"text":"${RES_FN}","expansion":[{"loc":{"start":0,"end":8},"parameter":"RES_FN","type":"ParameterExpansion"}],"type":"Word"},{"text":"--train_batch_size","type":"Word"},{"text":"${BS}","expansion":[{"loc":{"start":0,"end":4},"parameter":"BS","type":"ParameterExpansion"}],"type":"Word"},{"text":"--eval_batch_size","type":"Word"},{"text":"${BS}","expansion":[{"loc":{"start":0,"end":4},"parameter":"BS","type":"ParameterExpansion"}],"type":"Word"},{"text":"--max_source_length","type":"Word"},{"text":"${SRC_LEN}","expansion":[{"loc":{"start":0,"end":9},"parameter":"SRC_LEN","type":"ParameterExpansion"}],"type":"Word"},{"text":"--max_target_length","type":"Word"},{"text":"${TRG_LEN}","expansion":[{"loc":{"start":0,"end":9},"parameter":"TRG_LEN","type":"ParameterExpansion"}],"type":"Word"},{"type":"Redirect","op":{"text":">&","type":"greatand"},"file":{"text":"1","type":"Word"},"numberIo":{"text":"2","type":"io_number"}}]},{"type":"Command","name":{"text":"tee","type":"Word"},"suffix":[{"text":"${LOG}","expansion":[{"loc":{"start":0,"end":5},"parameter":"LOG","type":"ParameterExpansion"}],"type":"Word"}]}]}
REM Converted Windows Batch
