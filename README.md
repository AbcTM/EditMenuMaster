# EditMenuMaster

来自《iOS的文本编程指南》-显示和管理编辑菜单

编辑菜单是显示的上下文菜单，用于提供可以在诸如文本视图或图像中的单词之类的选择上执行的命令。编辑菜单是复制，剪切和粘贴操作的一个组成部分，可以显示（复制，剪切，粘贴，选择和全选）命令。但是，您可以将自定义菜单项添加到编辑菜单，以便对选择执行其他类型的操作。

管理选择和编辑菜单
要在视图中复制或剪切某些内容，或者使用其他方法执行其他操作，必须选择“某些内容”。它可以是文本，图像，URL，颜色或数据的任何其他表示形式，包括自定义对象。您必须自己管理该视图中对象的选择。如果用户通过做出特定的触摸手势（例如，双击）来选择视图中的对象，则必须处理该事件，在内部记录选择（并取消选择任何先前的选择），并且可能直观地指示新的选择风景。如果用户可以在视图中选择多个对象进行复制粘贴操作，则必须实现该多选行为。

注：  处理触摸事件的技巧（包括使用手势识别器）将在iOS的事件处理指南中讨论。

当您的应用程序确定用户请求了编辑菜单（可能是进行选择的操作）时，应完成以下步骤以显示菜单：

调用获取全局菜单控制器实例的sharedMenuController类方法。 UIMenuController
计算选择的边界并用所得的矩形调用setTargetRect:inView:方法。编辑菜单显示在矩形的上方或下方，取决于选择距离屏幕的顶部或底部多近。
调用setMenuVisible:animated:方法（使用YES这两个参数）来为选择上方或下方的编辑菜单的显示设置动画。
清单7-1说明了如何在touchesEnded:withEvent:处理复制，剪切和粘贴操作的方法的实现中显示编辑菜单。（请注意，该示例省略了处理选择的代码部分。）此代码片段还显示自定义视图发送自己的becomeFirstResponder消息，以确保它是后续复制，剪切和粘贴操作的第一响应者。

清单7-1   显示编辑菜单
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *theTouch = [touches anyObject];
 
    if ([theTouch tapCount] == 2  && [self becomeFirstResponder]) {
 
        // selection management code goes here...
 
        // bring up edit menu.
        UIMenuController *theMenu = [UIMenuController sharedMenuController];
        CGRect selectionRect = CGRectMake (currentSelection.x, currentSelection.y, SIDE, SIDE);
        [theMenu setTargetRect:selectionRect inView:self];
        [theMenu setMenuVisible:YES animated:YES];
 
    }
}
该菜单最初包括第一响应者具有对应UIResponderStandardEditActions方法实现的所有命令（copy:，paste:等等）。然而，在显示菜单之前，系统会向canPerformAction:withSender:第一个响应者发送消息，在很多情况下，这是自定义视图本身。在这个方法的实现中，响应者评估命令（由第一个参数中的选择符指示）是否适用于当前上下文。例如，如果选择器paste:和视图可以处理的类型的粘贴板中没有数据，响应者应该返回NO以禁止粘贴命令。如果第一响应者没有执行canPerformAction:withSender: 方法，或者不处理给定的命令，则消息遍历响应者链。

列表7-2示出的实施方案canPerformAction:withSender:，以查找匹配的消息的方法cut:，copy:和paste:选择器; 它将启用或禁用基于当前选择上下文的“复制”，“剪切”和“粘贴”菜单命令，并粘贴粘贴板的内容。

列表7-2   有条件地启用菜单命令

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    BOOL retValue = NO;
    ColorTile *theTile = [self colorTileForOrigin:currentSelection];
 
    if (action == @selector(paste:) )
        retValue = (theTile == nil) &&
             [[UIPasteboard generalPasteboard] containsPasteboardTypes:
             [NSArray arrayWithObject:ColorTileUTI]];
    else if ( action == @selector(cut:) || action == @selector(copy:) )
        retValue = (theTile != nil);
    else
        retValue = [super canPerformAction:action withSender:sender];
    return retValue;
}
请注意，else此方法中的最后一个子句调用超类实现，以使任何超类有机会处理子类选择忽略的命令。

请注意，一个菜单命令在执行时可以更改其他菜单命令的上下文。例如，如果用户选择视图中的所有对象，则复制和剪切命令应该包含在菜单中。在这种情况下，响应者可以在菜单仍然可见时调用update菜单控制器; 这导致canPerformAction:withSender:对第一响应者的重新配置。

添加自定义项目到编辑菜单
您可以将自定义项目添加到编辑菜单。当用户点击这个项目时，会发出一个以特定于应用程序的方式影响当前目标的命令。UIKit框架通过目标操作机制来完成。一个项目的点击导致一个动作消息被发送到响应者链中的第一个对象，该响应者链可以处理该消息。图7-1显示了自定义菜单项（“更改颜色”）的示例。

图7-1   带有自定义菜单项的编辑菜单

类的一个实例UIMenuItem表示一个自定义菜单项。UIMenuItem对象有两个属性，一个标题和一个动作选择器，你可以随时更改。要实现一个自定义菜单项时，必须初始化一个UIMenuItem具有这些特性的实例，该实例添加到自定义菜单项的菜单控制器的阵列，然后实现在适当的响应子处理指令的操作方法。

实现自定义菜单项的其他方面对于使用单例 UIMenuController对象的所有代码都是通用的。在自定义视图或覆盖视图中，将视图设置为第一个响应者，获取共享菜单控制器，设置目标矩形，然后通过调用显示编辑菜单setMenuVisible:animated:。清单7-3中的简单示例添加了一个自定义菜单项，用于在红色和黑色之间更改自定义视图的颜色。

清单7-3   实现一个Change Color菜单项

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {}
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *theTouch = [touches anyObject];
    if ([theTouch tapCount] == 2) {
        [self becomeFirstResponder];
        UIMenuItem *menuItem = [[UIMenuItem alloc] initWithTitle:@"Change Color" action:@selector(changeColor:)];
        UIMenuController *menuCont = [UIMenuController sharedMenuController];
        [menuCont setTargetRect:self.frame inView:self.superview];
        menuCont.arrowDirection = UIMenuControllerArrowLeft;
        menuCont.menuItems = [NSArray arrayWithObject:menuItem];
        [menuCont setMenuVisible:YES animated:YES];
    }
}
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {}
 
- (BOOL)canBecomeFirstResponder { return YES; }
 
- (void)changeColor:(id)sender {
    if ([self.viewColor isEqual:[UIColor blackColor]]) {
        self.viewColor = [UIColor redColor];
    } else {
        self.viewColor = [UIColor blackColor];
    }
    [self setNeedsDisplay];
}
注意：清单7-3中显示 的arrowDirection属性允许您指定附加到编辑菜单的箭头指向目标矩形的方向。UIMenuController

关闭编辑菜单
当您的系统或自定义命令的实现返回时，编辑菜单将自动隐藏。您可以使用以下代码行来保持菜单可见：

[UIMenuController sharedMenuController] .menuVisible = YES;
系统可能随时隐藏编辑菜单。例如，当显示警报或者用户点击屏幕的另一个区域时，它隐藏菜单。如果您的状态或显示取决于编辑菜单是否可见，您应该监听指定的通知UIMenuControllerWillHideMenuNotification并采取适当的措施。
