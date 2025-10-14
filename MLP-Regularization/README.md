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

通过残差块实现50层深度网络：
- 每个残差块：FC → BN → ReLU → Dropout → FC → BN → Skip Connection → ReLU
- 50个残差块堆叠

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

对比DeepMLP和DeepResidualMLP：
- 纯深度网络（DeepMLP）容易出现梯度消失/爆炸
- 残差连接通过跳跃连接保证梯度流畅
- ResidualMLP即使在50层深度下仍能正常训练
- 残差结构允许网络学习恒等映射，降低了优化难度

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
- 即使在50层深度，梯度仍能有效传播
- 残差连接提供了梯度的"高速公路"

## 结论

1. **BatchNorm** 是提升训练稳定性和收敛速度的有效方法，特别适合深层网络
2. **Dropout** 主要用于提升泛化能力，防止过拟合，在数据量有限时效果明显
3. **BatchNorm+Dropout** 组合使用时需要合理调参，但通常能获得最佳效果
4. **残差连接** 是构建深层网络的关键技术，能够有效解决梯度消失问题

在实际应用中，应根据具体任务特点（数据量、网络深度、过拟合程度等）选择合适的正则化策略。

## 文件说明

```
MLP-Regularization/
├── notebooks/
│   └── assignment2.ipynb      # 完整实验代码
├── results/                   # 实验结果图片
│   ├── simpleMLP_curves.png
│   ├── batchnorm_curves.png
│   ├── dropout_curves.png
│   ├── batchnorm_dropout_curves.png
│   ├── gradient_flow_*.png
│   └── ...
└── README.md                  # 本报告
```

## 参考资料

- Ioffe, S., & Szegedy, C. (2015). Batch Normalization: Accelerating Deep Network Training by Reducing Internal Covariate Shift.
- Srivastava, N., et al. (2014). Dropout: A Simple Way to Prevent Neural Networks from Overfitting.
- He, K., et al. (2016). Deep Residual Learning for Image Recognition.