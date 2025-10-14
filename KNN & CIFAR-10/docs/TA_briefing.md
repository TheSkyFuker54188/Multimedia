# 作业一助教汇报手册

---

## 1. 基本信息

- 课程作业：多媒体与机器学习 —— 第一次作业（KNN & CIFAR-10）
- 学生姓名 / 学号：李佳祎（2023202295）
- 仓库路径：`Assignment1/`
- 关键子目录：
  - `notebooks/` —— 两份待评分的 Jupyter Notebook
  - `notebooks/results/` —— Notebook 自动导出的截图、指标与模型文件
  - `src/` —— KNN 算法核心 Python 脚本
  - `docs/` —— 题目说明 (`TASK.md`) 与本手册

---

## 2. 提交物总览

| 序号 | 文件 / 文件夹                              | 作用                          | 备注                               |
| ---- | ------------------------------------------ | ----------------------------- | ---------------------------------- |
| 1    | `notebooks/assignment_knn.ipynb`         | KNN 与 NumPy 练习完整解答     | 已运行，末尾含可视化与结果保存单元 |
| 2    | `notebooks/assignment_CIFAR10_fit.ipynb` | CIFAR-10 卷积神经网络训练     | 已运行，自动写出所有指标/截图      |
| 3    | `notebooks/results/`                     | 所有截图、JSON 指标、模型权重 | 详见第 4 节                        |
| 4    | `src/k_nearest_neighbor.py`              | KNN 三种距离实现与预测逻辑    | Notebook 调用此模块                |
| 5    | `docs/TASK.md`                           | 官方作业要求                  | 已满足的要求详述见第 3 节          |

> **提醒**：仓库中已经把数据集解压到 `notebooks/data/cifar-10-batches-py/`，可直接使用；若需重新下载，可参考 Notebook 内的下载代码单元。

---

## 3. 与题目要求逐条对照

### 3.1 要求一：环境配置

- 依赖清单：Python 3.11、`numpy 1.26.x`、`torch 2.2.1+cpu`、`torchvision 0.17.1+cpu`、`matplotlib>=3.7`、`tqdm`
- 若无 `requirements.txt`，可按下述命令手动安装：
  ```powershell
  python -m venv .venv
  .\.venv\Scripts\activate
  pip install numpy==1.26.4 torch==2.2.1+cpu torchvision==0.17.1+cpu matplotlib tqdm
  ```
- Notebook 顶部单元已包含环境说明与随机种子设置。

### 3.2 要求二：KNN 作业 (`assignment_knn.ipynb`)

- 已完成内容：
  - NumPy 练习四题全部写出并配有演示代码；结果自动汇总为 `notebooks/results/numpy_answers.png`。
  - `src/k_nearest_neighbor.py` 中实现了三种距离函数与 `predict_labels`，Notebook 中给出耗时对比与正确性验证。
  - 绘图与实验结果：| 产出           | 文件                                          | 说明                                       |
    | -------------- | --------------------------------------------- | ------------------------------------------ |
    | 决策边界图     | `notebooks/results/knn_plot.png`            | 2D toy dataset 分类可视化                  |
    | k-准确率曲线   | `notebooks/results/knn_accuracy.png`        | k ∈ {1,3,5,7,9} 对比                      |
    | 距离矩阵热力图 | `notebooks/results/knn_distance_matrix.png` | 展示 no-loop 距离结果                      |
    | 指标 JSON      | `notebooks/results/knn_metrics.json`        | `{"best_k": 5, "final_accuracy": 0.278}` |
  - Notebook 最后一个单元会自动写出以上文件；助教只需执行 `Run all` 即可重现。

### 3.3 要求三：CIFAR-10 训练 (`assignment_CIFAR10_fit.ipynb`)

- 模型结构（`SimpleCNN`）：两段 `Conv-ReLU` + `MaxPool`，随后全连接层（256 -> 10），详见 Notebook 第 3 个代码单元。
- 训练配置：
  - 数据：CIFAR-10 子集（训练 5,000 样本 / 测试 800 样本，便于快速迭代）；如需全量，Notebook 中有注释提示如何切换。
  - Loss：`CrossEntropyLoss`
  - 优化器：`SGD(lr=0.01, momentum=0.9)`
  - 学习率调度：`StepLR(step_size=5, gamma=0.5)`
  - 训练轮次：`epochs = 8`
- 自动保存的产出：| 产出            | 文件                                            | 说明                                                                                                                           |
  | --------------- | ----------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------ |
  | 样本可视化      | `notebooks/results/cifar10_samples.png`       | 随机 16 张图像网格                                                                                                             |
  | 损失&准确率曲线 | `notebooks/results/cifar10_curves.png`        | 训练/测试 loss、accuracy                                                                                                       |
  | 误分类样本      | `notebooks/results/cifar10_misclassified.png` | 12 个误判案例 + 标签                                                                                                           |
  | 最终指标截图    | `notebooks/results/cifar10_final_metrics.png` | 末轮指标的文本图                                                                                                               |
  | 模型权重        | `notebooks/results/cifar10_model.pth`         | `torch.save` 导出的 state_dict                                                                                               |
  | 指标 JSON       | `notebooks/results/cifar10_metrics.json`      | `{"final_train_loss": 1.3972, "final_test_loss": 1.5023, "final_train_acc": 0.4894, "final_test_acc": 0.43625, "epochs": 8}` |
- Notebook 末尾同样提供一键保存单元；执行全部单元即可生成上述文件。

### 3.4 要求四：打包提交

- 若助教需要重新打包，推荐 PowerShell 命令：
  ```powershell
  $NAME="李佳祎"; $SID="2023202295"
  $OUTDIR="assignment1_${NAME}_${SID}"
  New-Item -ItemType Directory -Path $OUTDIR -Force | Out-Null
  Copy-Item .\Assignment1\notebooks\assignment_knn.ipynb $OUTDIR\
  Copy-Item .\Assignment1\notebooks\assignment_CIFAR10_fit.ipynb $OUTDIR\
  Copy-Item .\Assignment1\notebooks\results $OUTDIR -Recurse
  Copy-Item .\Assignment1\README.md $OUTDIR\
  # 若已准备 requirements.txt，则一并复制
  Copy-Item .\Assignment1\requirements.txt $OUTDIR\ -ErrorAction SilentlyContinue
  Compress-Archive -Path $OUTDIR -DestinationPath "${OUTDIR}.zip" -Force
  ```
- 压缩包命名规范：`assignment1_李佳祎_2023202295.zip`

---

## 4. 运行与验收流程（建议助教按序执行）

1. **环境准备**
   - （可选）创建虚拟环境并安装依赖。
   - 检查 `git lfs ls-files`，确认 `Assignment1/notebooks/data/cifar-10-python.tar.gz` 已由 Git LFS 管理。
2. **验收 KNN Notebook**
   - 打开 `notebooks/assignment_knn.ipynb` → `Kernel` → `Restart & Run All`。
   - 运行结束后，确认 `notebooks/results/` 下的四张 PNG + `knn_metrics.json` 更新。
   - 对照 JSON 中 `best_k=5`、`final_accuracy=0.278`。
3. **验收 CIFAR-10 Notebook**
   - 打开 `notebooks/assignment_CIFAR10_fit.ipynb` → 运行全部单元。
   - 结束后检查 `cifar10_metrics.json` 数值：
     - 训练损失 `1.3972`
     - 测试损失 `1.5023`
     - 训练准确率 `48.94%`
     - 测试准确率 `43.63%`
     - 轮次 `8`
   - 对照生成的 PNG 与 `cifar10_model.pth` 是否存在。
4. **整理汇报**
   - 汇总以上指标到课程要求的文档或表格。
   - 若需提交压缩包，执行第 3.4 节脚本。

---

## 5. 额外说明

- **数据管理**：原始 `cifar-10-python.tar.gz` 由 Git LFS 管理，拉取仓库前需先安装 Git LFS（`git lfs install`），否则会得到指针文件。
- **运行时间**：KNN Notebook < 2 分钟；CIFAR-10 Notebook 在 CPU 上约 15~20 分钟（取决于机器配置）。
- **可选改进**：Notebook 尾部列出后续可尝试的增强策略（数据增强、Adam/AdamW、早停等），可作为追加实验参考。
- **联系信息**：如需更多细节，可参考仓库根目录的 `README.md`，其中有更细致的复现说明与改进建议。

---

> 本手册保持随镝更新。如助教发现仓库结构或指标有变化，请在 `docs/TA_briefing.md` 中追加批注或版本号。
