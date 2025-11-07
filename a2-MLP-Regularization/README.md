# MLP正则化技术实验报告

## 实验目的

本次实验主要探究BatchNorm、Dropout以及残差连接（Residual Connection）等正则化技术在多层感知机（MLP）网络中的应用效果，通过在CIFAR-10数据集上的实验，对比分析不同正则化方法对模型训练稳定性、收敛速度和泛化能力的影响。

## 实验环境

- **框架**: PyTorch
- **数据集**: CIFAR-10（使用5000张训练图片，500张测试图片）
- **优化器**: Adam (学习率 0.001)
- **训练轮数**: 10 epochs
- **批次大小**: 256

## 网络架构设计

### 1. 基础MLP（SimpleMLP）

最简单的三层全连接网络，作为对照组：

- 输入层：3072维（32×32×3）
- 隐藏层1：512个神经元 + ReLU
- 隐藏层2：512个神经元 + ReLU
- 输出层：10个类别

### 2. BatchNorm-MLP

在全连接层后加入BatchNorm层：

- FC1 → BatchNorm → ReLU
- FC2 → BatchNorm → ReLU
- FC3（输出）

### 3. Dropout-MLP

在激活函数后加入Dropout层（p=0.5）：

- FC1 → ReLU → Dropout
- FC2 → ReLU → Dropout
- FC3（输出）

### 4. BatchNorm+Dropout-MLP

结合两种正则化方法：

- FC1 → BatchNorm → ReLU → Dropout
- FC2 → BatchNorm → ReLU → Dropout
- FC3（输出）

### 5. 深度残差MLP

通过残差块实现深层网络（20层）：

- 每个残差块：FC → BN → ReLU → Dropout(0.3) → FC → BN → Skip Connection → ReLU
- 20个残差块堆叠
- 使用较低学习率（5e-4）与梯度裁剪保证训练稳定性

## 实验改进与优化

在初版实验中发现了以下问题并进行了优化：

**发现的问题：**

1. **Optimizer重置问题**：训练函数内部每epoch重新创建optimizer，导致Adam动量统计被清零
2. **数据未打乱**：DataLoader的shuffle=False导致每epoch看到相同顺序的样本
3. **深层网络不稳定**：50层深度+高dropout(0.5)+较大学习率导致训练出现极端loss峰值
4. **过拟合严重**：小数据集(5000样本)+大模型+无数据增强导致test loss持续上升

**优化措施：**

1. 将optimizer创建移到训练循环外部，保持动量统计的连续性
2. 训练集DataLoader启用shuffle=True，并添加数据增强(RandomCrop+HorizontalFlip)
3. 深层模型：减少层数(50→20)，降低dropout(0.5→0.3)，降低学习率(1e-3→5e-4)
4. 添加梯度裁剪(max_norm=5.0)防止梯度爆炸
5. 增加accuracy对比图(comparison_accuracy.png)便于直观对比

## 实验结果分析

### 训练效果对比

根据实验结果，各模型的表现如下：

**1. BatchNorm的作用**

BatchNorm显著提升了训练稳定性。通过对每一层的输入进行归一化，解决了内部协变量偏移（Internal Covariate Shift）问题。从Loss曲线可以看出：

- 收敛速度更快
- 训练过程更加平稳，波动较小
- 测试集上泛化性能有明显提升

**2. Dropout的效果**

Dropout通过随机失活神经元，强制网络学习更加鲁棒的特征：

- 有效防止过拟合
- 训练Loss可能略高于基础模型
- 但测试Loss通常更低，说明泛化能力更强
- 训练过程可能出现较大波动（因为每次前向传播使用不同的子网络）

**3. BatchNorm+Dropout组合**

两种技术结合使用时：

- 训练稳定性最佳（得益于BatchNorm）
- 泛化能力最强（得益于Dropout）
- 在小数据集上效果尤为明显
- 但需要注意两者的顺序和dropout rate的选择

**4. 深度网络与残差连接**

对比DeepMLP和DeepResidualMLP（经优化后）：

- 纯深度网络（DeepMLP）即使在20层+BatchNorm的情况下，仍需要较低学习率才能稳定训练
- 残差连接通过跳跃连接有效缓解梯度消失，使深层网络训练更加平稳
- 在降低层数(20层)和dropout(0.3)后，ResidualMLP训练曲线更加稳定，无极端峰值
- 残差结构允许网络学习恒等映射，降低了优化难度，是构建深层MLP的关键技术

**5. 数据增强与打乱的重要性**

修复前后对比显示：

- 启用shuffle后，模型不再对固定顺序样本"记忆"，泛化能力显著提升
- 添加RandomCrop和HorizontalFlip后，过拟合现象明显延后
- 小数据集场景下，数据增强是最直接有效的正则化手段之一

### 梯度流分析

通过可视化各模型的梯度流，我们观察到：

**SimpleMLP**:

- 梯度在深层逐渐衰减
- 可能出现梯度消失现象

**MLPWithBatchNorm**:

- 各层梯度分布更加均匀
- BatchNorm起到了梯度归一化的作用

**MLPWithDropout**:

- 梯度幅度略有增加
- 但分布较为分散（因为随机性）

**MLPWithBatchNormDropout**:

- 结合了两者的优点
- 梯度既均匀又适中

**DeepResidualMLP**:

- 在20层深度下，梯度能够有效传播到前层
- 残差连接提供了梯度的"高速公路"，配合较低dropout和梯度裁剪，训练过程稳定

## 结论与建议

### 核心发现

1. **BatchNorm** 是提升训练稳定性和收敛速度的有效方法，特别适合深层网络，但单独使用不能防止过拟合
2. **Dropout** 主要用于提升泛化能力，防止过拟合，在数据量有限时效果明显，是小数据集场景的主要正则化手段
3. **BatchNorm+Dropout** 组合需要合理调参（dropout rate通常可降低到0.2~0.3），避免过度正则化
4. **残差连接** 是构建深层网络的关键技术，能够有效解决梯度消失问题，但需配合较低学习率、梯度裁剪和适度dropout
5. **数据增强与shuffle** 在小数据集上的作用不可忽视，往往比复杂网络结构更有效

### 实践建议

- **小数据集（<10k样本）**：优先使用Dropout + 数据增强，BatchNorm可选
- **深层网络（>10层）**：必须使用残差连接 + BatchNorm，配合梯度裁剪
- **调参顺序**：先固定基础设置（shuffle、optimizer持久化），再调网络结构，最后微调超参数
- **过拟合检测**：始终监控train/test loss差距，及时引入正则化
- **深层训练**：降低学习率（5e-4或更低）、减少层数、降低dropout rate、使用梯度裁剪

在实际应用中，应根据具体任务特点（数据量、网络深度、过拟合程度等）选择合适的正则化策略，并重视训练流程的正确性（optimizer状态保持、数据打乱等）。

## 文件说明

```
MLP-Regularization/
├── notebooks/
│   └── assignment2.ipynb      # 完整实验代码
├── results/                   # 实验结果图片
│   ├── simpleMLP_loss_acc_curve.png
│   ├── batchnorm_loss_acc_curve.png
│   ├── dropout_loss_acc_curve.png
│   ├── batchnorm_dropout_loss_acc_curve.png
│   ├── deepMLP_loss_acc_curve.png
│   ├── deepResidualMLP_loss_acc_curve.png
│   ├── gradient_flow_*.png      # 各模型梯度流可视化
│   └── comparison_accuracy.png  # 所有模型accuracy对比
└── README.md                     # 本报告
```
