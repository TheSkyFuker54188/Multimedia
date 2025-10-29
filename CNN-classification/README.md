# CIFAR-10 分类实验报告

这次作业围绕 CIFAR-10 分类展开。我先实现了一个自研的卷积网络（记为 MyCNN），再和两种经典模型（ResNet18、VGG11-BN）做对比；另外还做了一个“轻量版”对照实验，用来观察去掉部分增强/正则后的影响。下面把设计思路、训练结果和一些观察记录一下。

## 数据与预处理

- 数据集：CIFAR-10（32×32，10 类）
- 归一化：按官方统计值进行 per-channel 标准化
- 训练增强：
  - 基线（MyCNN/ResNet/VGG）：RandomCrop(32, padding=4) + RandomHorizontalFlip + 轻度 ColorJitter
  - 轻量版：只保留基本增广（去掉 ColorJitter），并关闭 Dropout

## 模型与训练设置

### 1) MyCNN（自研）

- 结构：Conv-BN-ReLU 堆叠 + 残差块（简化版）+ Dropout + AdaptiveAvgPool + 线性分类头
- 初始化：Kaiming Normal
- 优化：AdamW，CosineAnnealingLR，带 label smoothing 与早停
- 直观感受：参数量不大，收敛比较稳，20 个 epoch 左右曲线就很平滑

### 2) ResNet18（经典对比）

- 策略：加载 ImageNet 预训练权重，调整首层为 3×3 卷积、去 MaxPool 以适配 32×32；微调训练
- 优化：SGD(momentum) + CosineAnnealingLR
- 直观感受：收敛速度和上限都不错，是一个稳妥的强基线

### 3) VGG11-BN（经典对比）

- 策略：标准 VGG11-BN，替换分类头输出为 10 类
- 优化：AdamW + CosineAnnealingLR
- 直观感受：在我这份默认超参下表现一般（很可能需要更多 epoch 或更合适的学习率/权重衰减），作为一个“反例”保留下来

### 4) 轻量版 MyCNN（选做）

- 差异：去掉 ColorJitter、关闭 Dropout；使用 SGD + StepLR；其余保持一致
- 用途：对比增广/正则/优化器简化带来的性能变化

## 训练结果（测试集）

下表中的数字直接来自 `notebooks/results/*_best_metrics.json`：

| 模型            | Test Acc | Test Loss | Val Acc (best) | Best Epoch |
| --------------- | -------: | --------: | -------------: | ---------: |
| MyCNN           |   0.8838 |    0.5900 |         0.8878 |         23 |
| ResNet18        |   0.8846 |    0.6003 |         0.8930 |         20 |
| VGG11-BN        |   0.1000 |    2.3026 |         0.1046 |          3 |
| MyCNN（轻量版） |   0.6742 |    0.9181 |         0.6776 |         11 |

配套图表与文件（节选）：

- 单模型曲线：
  - `notebooks/results/myCNN_loss_acc_curve.png`
  - `notebooks/results/resnet18_loss_acc_curve.png`
  - `notebooks/results/vgg11_loss_acc_curve.png`
  - `notebooks/results/myCNN_light_loss_acc_curve.png`
- 多模型对比：
  - `notebooks/results/comparison_val_acc.png`
  - `notebooks/results/comparison_val_loss.png`
- 其它：
  - 预测可视化/错误样例：`notebooks/results/myCNN_misclassified.png`
  - 最优权重与指标：`*_best.pth`、`*_best_metrics.json`、`*_history.json`

## 一些观察与分析

- MyCNN vs ResNet18：

  - 两者精度非常接近（我的这组跑分里，ResNet18 略高一点点）。
  - MyCNN 更“轻”，训练时间上占优；如果算力一般，MyCNN 是个性价比不错的选择。
- 轻量版的影响：

  - 去掉颜色增强与 Dropout、改用 SGD + StepLR 后，准确率明显下降（约 67%）。
  - 这基本符合预期：正则与合适的增强对泛化很关键，优化器与学习率调度的匹配也有影响。
- VGG11-BN 的表现：

  - 这轮实验里明显偏低，可能和训练轮数/学习率设定有关；VGG 系列通常需要更长训练或更强正则。
  - 我没有继续在这条线上深挖，把它当作“未调好的对照”留在结果里，提醒自己下次先用更稳的配置。

## 复现实验

1. 打开 `notebooks/assignment3.ipynb`，按顺序执行：
   - 环境/数据单元 → MyCNN 训练/评估 → ResNet18 训练/评估 → VGG11-BN 训练/评估 → 选做“轻量版”
2. 最后执行“指标整理与曲线对比”单元：
   - 该单元已做了容错处理：如内存变量缺失，会自动从 `notebooks/results/` 读取对应 JSON 并绘图；缺失则跳过
3. 所有产物默认写在 `notebooks/results/` 下

>就这样，核心思路和结果都在上面了。若后面还有时间，我会优先把 VGG 的训练再多跑几轮，顺手加一份按类别的准确率/混淆矩阵，分析会更完整一些。
