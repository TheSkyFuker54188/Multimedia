## 【第二次作业要求】

1. **完成 `assignment2.ipynb` 中的填空与实验：**

   * **模型设计部分：**
   * 实现带有 **BatchNorm 层** 的 MLP 模型
   * 实现带有 **Dropout 层** 的 MLP 模型
   * 实现同时包含 **BatchNorm + Dropout** 的 MLP 模型
   * 实现一个通过**Residual Block**达到更深层次的MLP模型
   * 完成文档末尾梯度流可视化功能的编写
   * **训练与测试部分：**
   * 补全训练代码，训练上述模型并记录训练/测试 loss及Acc。
   * **分析部分：**

   1. 哪种模型在训练过程中表现最好？
   2. BatchNorm 和 Dropout 分别如何影响训练稳定性与梯度流？结合 loss 曲线与梯度图，解释这些机制的作用。
2. **提交内容包括：**

   * 填空完成并运行成功的 `assignment2.ipynb` 文件。
   * 所有运行结果截图（训练曲线、梯度流可视化结果、比较图等）。
3. **打包与命名格式：**

   * 将 `.ipynb` 文件和所有截图打包为 `.zip` 文件，命名格式如下：
     ```
     assignment2_姓名_学号.zip
     ```

### 文件结构示例

```
assignment2_姓名_学号/
├── notebooks/
│   └── assignment2.ipynb
├── results/
│   ├── simpleMLP_loss/acc_curve.png
│   ├── batchnorm_loss/acc_curve.png
│   ├── dropout_loss/acc_curve.png
│   ├── batchnorm_dropout_loss/acc_curve.png
│   ├── gradient_flow_simpleMLP.png
│   ├── gradient_flow_batchnorm.png
│   ├── gradient_flow_dropout.png
│   ├── gradient_flow_batchnorm_dropout.png
│   └── comparison_accuracy.png （可选）
└── README.txt        # （可选）简要说明截图内容与分析结果
```
