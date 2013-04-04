//
// RETableViewTextCell.m
// RETableViewManager
//
// Copyright (c) 2013 Roman Efimov (https://github.com/romaonthego)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//

#import "RETableViewTextCell.h"
#import "RETableViewManager.h"

@implementation RETableViewTextCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.textLabel.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)cellDidLoad
{
    [super cellDidLoad];
    
    _textField = [[UITextField alloc] initWithFrame:CGRectNull];
    
    _textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    _textField.inputAccessoryView = self.actionBar;
    _textField.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _textField.delegate = self;
    [_textField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [self addSubview:_textField];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    if (selected) {
        [_textField becomeFirstResponder];
    }
}

- (void)prepare
{
    [super prepare];
    
    self.textLabel.text = self.item.title;
    _textField.text = self.item.value;
    _textField.placeholder = self.item.placeholder;
    _textField.font = self.tableViewManager.style.textFieldFont;
    _textField.autocapitalizationType = self.item.autocapitalizationType;
    _textField.autocorrectionType = self.item.autocorrectionType;
    _textField.spellCheckingType = self.item.spellCheckingType;
    _textField.keyboardType = self.item.keyboardType;
    _textField.keyboardAppearance = self.item.keyboardAppearance;
    _textField.returnKeyType = self.item.returnKeyType;
    _textField.enablesReturnKeyAutomatically = self.item.enablesReturnKeyAutomatically;
    _textField.secureTextEntry = self.item.secureTextEntry;
    
    _textFieldPositionOffset = self.tableViewManager.style.textFieldPositionOffset;
}

- (UIResponder *)responder
{
    return _textField;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat cellOffset = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ? 20 : 60;
    CGFloat fieldOffset = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ? 10 : 40;
    CGFloat width = 0;
    CGRect frame = CGRectMake(0, _textFieldPositionOffset.height, 0, self.frame.size.height - _textFieldPositionOffset.height);
    if (self.item.title && ![self.item.title isEqualToString:@""]) {
        for (RETableViewItem *item in self.section.items) {
            if ([item isKindOfClass:[RETextItem class]] || [item isKindOfClass:[RENumberItem class]]) {
                CGSize size = [item.title sizeWithFont:self.textLabel.font];
                width = MAX(width, size.width);
            }
        }
        frame.origin.x = width + cellOffset + fieldOffset + _textFieldPositionOffset.width;
    } else {
        frame.origin.x = cellOffset + _textFieldPositionOffset.width;
    }
    frame.size.width = self.frame.size.width - frame.origin.x - cellOffset;
    _textField.frame = frame;
}

#pragma mark -
#pragma mark Text field events

- (void)textFieldDidChange:(UITextField *)textField
{
    self.item.value = textField.text;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    NSIndexPath *indexPath = [self indexPathForNextResponder];
    if (indexPath) {
        textField.returnKeyType = UIReturnKeyNext;
    } else {
        textField.returnKeyType = UIReturnKeyDefault;
    }
    [self refreshActionBar];
    [self.parentTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.row inSection:self.sectionIndex] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    return YES;
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    NSIndexPath *indexPath = [self indexPathForNextResponder];
    if (!indexPath) {
        [self endEditing:YES];
        return YES;
    }
    RETableViewCell *cell = (RETableViewCell *)[self.parentTableView cellForRowAtIndexPath:indexPath];
    [cell.responder becomeFirstResponder];
    return YES;
}

@end
