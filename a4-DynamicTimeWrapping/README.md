# 作业4：基于 DTW 的语音匹配与识别（实验报告）

本文记录本次作业的实现过程、参数设定、结果展示与分析，并给出可复现实验的运行说明。报告基于 `notebooks/assignment4.ipynb` 的最终实现与运行结果整理。

## 实验内容概述

- 语音特征提取：对每段语音提取 MFCC 特征，并叠加一阶/二阶差分后做帧内均值聚合，得到稳定的窗口级表征。
- DTW 路径匹配：实现动态时间规整（DTW）以衡量两段语音的相似度；支持 Sakoe-Chiba 动态带宽约束；可切换距离度量（平方欧氏、欧氏、余弦）。
- 小型识别任务：在训练集上为每个数字构建 master template，并在测试集上做模板匹配识别；输出整体准确率与混淆矩阵等指标。
- 选做对比：对不同带宽/距离度量进行对比，记录精度与耗时，观察速度-精度权衡。

## 代码与数据组织

- Notebook：`notebooks/assignment4.ipynb`
- 训练/测试数据：`notebooks/data/`
- 结果输出：`results/`（由 Notebook 自动创建并写入）

## 关键实现与参数

1. 特征提取（WavtoMfcc）
	- 多通道转单通道：对多声道音频进行均值融合为 mono。
	- 预处理：去直流分量；滑窗分段（默认 `segment_len=1000`、`hop_len=1000`，必要时使用 reflect padding 保证每段等长）。
	- MFCC：`numceps=13`，`winlen=0.025s`，`winstep=0.01s`，`nfilt=26`，`nfft=2048`，`preemph=0.97`。
	- 动态信息：计算 Δ 与 ΔΔ，并在帧维做均值，得到窗口级 39 维表示。

2. 匹配与识别
	- 代价函数：支持 `sqeuclidean`、`euclidean`、`cosine` 三种度量。
	- DTW：可选 Sakoe-Chiba 带宽（例如 20/40），默认全窗口。
	- Master 模板：对同类样本通过 DTW 对齐后在路径上做逐点平均，得到更鲁棒的代表性模板；再在类内做候选模板打分，选择平均代价最低者。

## 结果与可视化

结果图片均保存在 `results/` 目录，主要包含：

- `mfcc_feature.png`：样例语音的 MFCC（含 Δ/ΔΔ 聚合后）可视化。
- `dtw_distance_matrix.png`：样例两段语音的两两帧间距离矩阵（可直观观察对齐难度）。
- `confusion_matrix.png`：在测试集上的混淆矩阵。
- `accuracy_summary.png`：按数字类别统计的分类准确率条形图。
- `optional_experiments.png`：选做实验中不同带宽/距离度量的精度与耗时对比图。

此外，Notebook 还会保存 `results/evaluation_stats.npz`，包含：

- `overall_acc`：整体识别准确率；
- `conf_mat`：混淆矩阵；
- `per_class_acc`：每类准确率。

> 注：具体数值会随随机种子、环境及实现细节略有波动。上述图表和 `.npz` 文件来自实际运行结果，可直接复核。

## 实验分析（简要）

- MFCC + Δ/ΔΔ 能较好地捕捉短时谱特征和动态信息；在说话速度差异时，DTW 的时间弹性有助于对齐。
- Sakoe-Chiba 适度的带宽（例如 20 左右）通常能在计算量与精度间取得平衡；过窄会限制路径、可能伤害精度，过宽则耗时显著增加。
- 距离度量上，余弦距离对能量尺度不敏感，适用于说话人音量差异较大的场景；欧氏/平方欧氏实现简单、表现稳定。
- DTW 的主要瓶颈在于时间复杂度（近似二次）；如需进一步提速，可考虑 FastDTW、下采样、特征降维或限制搜索窗等手段。

## 运行与复现

1. 环境准备（建议在 Notebook 内核环境中安装）：

	```python
	%pip install python_speech_features numpy scipy matplotlib
	```

2. 打开并顺序运行 `notebooks/assignment4.ipynb`：
	- 生成 master 模板并对测试集评估；
	- 自动在 `results/` 下生成图表与 `evaluation_stats.npz`；
	- 可运行选做实验单元，得到 `optional_experiments.png` 与 `optional_experiments.json`。

## 打包与提交

按题目要求，将下列内容打包为 `assignment4_姓名_学号.zip`：

```
assignment4_姓名_学号/
├── notebooks/
│   └── assignment4.ipynb
├── results/
│   ├── mfcc_feature.png
│   ├── dtw_distance_matrix.png
│   ├── confusion_matrix.png
│   ├── accuracy_summary.png
│   ├── optional_experiments.png        # 若完成选做
│   └── evaluation_stats.npz            # 运行自动生成
└── README.txt  # 可选，简述运行方式与备注
```

若需复核运行日志或参数，可以在 Notebook 中查看对应单元的注释与输出。

