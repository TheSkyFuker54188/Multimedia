# 【第五次作业要求】

> 根据requirements配置python环境，完成 `assignment5.ipynb` 中的填空与实验，实现一个基于 CNN encoder + LSTM decoder 的 image captioning 系统，完成模型设计、训练、评估与分析，在Flickr8K上进行实验。

## Task 1：完成 caption 文本预处理

## Task 2：实现 captioning 模型结构

## Task 3：实现自回归 caption 生成

## Task 4：训练与验证

* 记录并保存每个 epoch 的训练 loss 与验证 loss
* 保存最优模型（按验证指标或验证 loss）
* 在 notebook 中给出若干定性样例（至少 10 张图像）并展示生成的 caption 与 ground-truth captions

## 拓展实验

1. 尝试将LSTM替换为 GRU/Transformer 模型，比较结果
2. 查找其他captioning任务的评测指标并实现，对结果进行评测

# 提交内容

* 完成并能运行的 `assignment5.ipynb`（填空完成，含结果展示）
* 保存的模型参数
* 所有训练结果截图（loss/accuracy/metric 曲线、示例生成图片等）
* `README.txt`：简要说明模型设计、训练细节（超参数）、如何运行 notebook、以及关键发现与结论

# 打包与命名格式

将 `.ipynb`、模型、结果截图、README 打包为 `.zip`，命名格式如下：

```
assignment5_姓名_学号.zip
```

示例文件结构：

```
assignment5_姓名_学号/
├── notebooks/
│   └── assignment5.ipynb
├── models/
│   └── best_model.pth
├── results/
│   ├── train_val_loss_curve.png
│   ├── bleu_scores.png
│   └── qualitative_examples_n.png （生成结果，至少n=10张图片）
└── README.txt （可选）
```
