# Assignment 1 Report
#### 李佳祎 2023202295
> 课程第一次作业总结（KNN + CIFAR-10）。本 README 汇总环境信息、实现说明、结果指标与复现步骤，方便助教快速核查。

## 目录
- [Assignment 1 Report](#assignment-1-report)
      - [](#)
  - [目录](#目录)
  - [环境与依赖](#环境与依赖)
  - [项目结构](#项目结构)
  - [KNN 部分](#knn-部分)
  - [CIFAR-10 部分](#cifar-10-部分)
  - [结果汇总](#结果汇总)
    - [KNN](#knn)
    - [CIFAR-10 (子集)](#cifar-10-子集)
  - [如何复现](#如何复现)
  - [可改进方向](#可改进方向)

## 环境与依赖
| 组件        | 版本 (示例) |
| ----------- | ----------- |
| Python      | 3.11.x      |
| numpy       | 1.26.x      |
| torch       | 2.2.1+cpu   |
| torchvision | 0.17.1+cpu  |
| matplotlib  | >=3.7       |
| tqdm (可选) | >=4.0       |

生成依赖：
```bash
pip freeze > requirements.txt
```

## 项目结构
```
Assignment1/
  docs/
    TASK.md
    GD.png
    guild/
      numpy tutorial.ipynb
      Neural_Network_simple_tutorial_sin_fit.ipynb
  notebooks/
    assignment_knn.ipynb
    assignment_CIFAR10_fit.ipynb
    results/
      knn_plot.png
      knn_accuracy.png
      knn_distance_matrix.png
      numpy_answers.png
      knn_metrics.json
      cifar10_samples.png
      cifar10_curves.png
      cifar10_metrics.json
      cifar10_misclassified.png
      cifar10_model.pth
      cifar10_final_metrics.png
  src/
    k_nearest_neighbor.py
    helpers.py
  README.md
  requirements.txt
```

## KNN 部分
实现文件：`src/k_nearest_neighbor.py`

核心函数：
- `compute_distances_two_loops`
- `compute_distances_one_loop`
- `compute_distances_no_loops`（向量化实现，利用 `(x - y)^2 = ||x||^2 + ||y||^2 - 2x·y`）
- `predict_labels`

Notebook 内容包含：
- NumPy 练习（自动汇总图：`numpy_answers.png`）
- 三种距离耗时与差异（范数差 ~ 1e-12 量级）
- k vs accuracy 曲线（`knn_accuracy.png`）
- Toy 数据集决策边界（`knn_plot.png`）
- 距离矩阵可视化（`knn_distance_matrix.png`）
- 指标 JSON：`knn_metrics.json`（含最佳 k 与最终准确率）

## CIFAR-10 部分
模型：`SimpleCNN`
```
Conv(3,32) -> ReLU -> Conv(32,32) -> ReLU -> MaxPool
Conv(32,64) -> ReLU -> Conv(64,64) -> ReLU -> MaxPool
Flatten -> Linear(64*8*8,256) -> ReLU -> Linear(256,10)
```
优化与训练：
- Loss: CrossEntropyLoss
- Optimizer: SGD(lr=0.01, momentum=0.9)
- Scheduler: StepLR(step_size=5, gamma=0.5)
- 子集训练：5000 训练样本 / 800 测试样本（可切换为全量）
- 随机种子固定：`42`

自动保存：
- 样本图：`cifar10_samples.png`
- Loss+Accuracy 曲线：`cifar10_curves.png`
- 误分类样本：`cifar10_misclassified.png`
- 模型权重：`cifar10_model.pth`
- 终局文本指标图：`cifar10_final_metrics.png`
- JSON 指标：`cifar10_metrics.json`

## 结果汇总
（示例，具体数值以实际运行生成的 JSON 为准）

### KNN
| 指标           | 数值                    |
| -------------- | ----------------------- |
| best_k         | (from knn_metrics.json) |
| final_accuracy | (from knn_metrics.json) |

### CIFAR-10 (子集)
| 指标             | 数值                        |
| ---------------- | --------------------------- |
| final_train_loss | (from cifar10_metrics.json) |
| final_test_loss  | (from cifar10_metrics.json) |
| final_train_acc  | (from cifar10_metrics.json) |
| final_test_acc   | (from cifar10_metrics.json) |
| epochs           | (cifar10_metrics.json)      |

> 注：使用子集仅用于快速迭代，准确率不代表最终上限。可扩大到全量 50k/10k 继续训练。

## 如何复现
1. 创建环境并安装依赖：
```bash
pip install -r requirements.txt
```
2. 运行 KNN：打开 `assignment_knn.ipynb` 全部执行，会在 `notebooks/results/` 下生成相关图片与 JSON。
3. 运行 CIFAR-10：打开 `assignment_CIFAR10_fit.ipynb` 全部执行，生成 CNN 训练结果文件。
4. 打包提交（PowerShell）：
```powershell
$NAME="张三"; $SID="20250001"
$OUTDIR="assignment1_${NAME}_${SID}"
New-Item -ItemType Directory -Path $OUTDIR -Force | Out-Null
New-Item -ItemType Directory -Path "$OUTDIR/notebooks" -Force | Out-Null
New-Item -ItemType Directory -Path "$OUTDIR/results" -Force | Out-Null
Copy-Item .\Assignment1\notebooks\assignment_knn.ipynb $OUTDIR\notebooks\
Copy-Item .\Assignment1\notebooks\assignment_CIFAR10_fit.ipynb $OUTDIR\notebooks\
Copy-Item .\Assignment1\notebooks\results\*.png $OUTDIR\results\
Copy-Item .\Assignment1\notebooks\results\*.json $OUTDIR\results\
Copy-Item .\Assignment1\notebooks\results\*.pth $OUTDIR\results\ -ErrorAction SilentlyContinue
Copy-Item .\Assignment1\requirements.txt $OUTDIR\
Compress-Archive -Path $OUTDIR -DestinationPath "${OUTDIR}.zip" -Force
```

## 可改进方向
| 方向       | 说明                                    |
| ---------- | --------------------------------------- |
| 数据增强   | RandomCrop / HorizontalFlip 提升泛化    |
| 更优优化器 | Adam / AdamW 加速收敛                   |
| 正则化     | Dropout / Weight Decay 抑制过拟合       |
| 学习率策略 | CosineAnnealing / OneCycleLR            |
| 更深结构   | ResNet / EfficientNet 作为后续提升      |
| 早停       | 监控验证集 loss 防止过拟合              |
| 全量训练   | 使用完整 50k/10k CIFAR10 获得更高准确率 |

---
如需进一步改进或添加实验记录表格，可继续在 README 末尾附加 `EXPERIMENT_LOG.md`。
