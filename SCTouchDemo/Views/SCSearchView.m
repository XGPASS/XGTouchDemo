//
//  SCSearchView.m
//  Butler
//
//  Created by 小广 on 2017/1/19.
//  Copyright © 2017年 UAMA Inc. All rights reserved.
//

#import "SCSearchView.h"

@interface SCSearchView ()<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIView *bgView;
@property (weak, nonatomic) IBOutlet UIButton *titleButton;
@property (weak, nonatomic) IBOutlet UIButton *scanButton;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UIImageView *searchArrowImage;
@property (weak, nonatomic) IBOutlet UIButton *addressButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *scanButtonWidth;
@property (nonatomic, copy) SCSearchBarBlock textBlock;
@property (nonatomic, copy) SCSearchButtonBlock buttonBlock;

@end

@implementation SCSearchView

#pragma mark - 对外方法
+ (id)loadNibView {
    return [[[NSBundle mainBundle] loadNibNamed:@"SCSearchView" owner:self options:nil] objectAtIndex:0];
}

- (void)searchBarAction:(SCSearchButtonBlock)block {
    self.buttonBlock = block;
}

- (void)gainSearchText:(SCSearchBarBlock)textBlock {
    self.textBlock = textBlock;
}

#pragma mark - 内部方法
- (void)awakeFromNib {
    [super awakeFromNib];
    self.clipsToBounds = YES;
    [self.bgView.layer setMasksToBounds:YES];
    self.bgView.layer.cornerRadius = 3.0;
    self.textField.delegate = self;
    self.searchType = SCSearchTypeNormal;
    self.showScan = YES;
    [_addressButton setTitle:@"请选择业主地址" forState:UIControlStateNormal];
}

- (void)setSearchType:(SCSearchType)searchType {
    _searchType = searchType;
    [self setupUI];
}

- (void)setSearchTypeString:(NSString *)searchTypeString {
    [_titleButton setTitle:searchTypeString forState:UIControlStateNormal];
}

- (void)setAddressString:(NSString *)addressString {
    [_addressButton setTitle:addressString forState:UIControlStateNormal];
}

- (void)setSearchText:(NSString *)searchText {
    _textField.text = searchText;
}

- (void)setShowScan:(BOOL)showScan {
    _showScan = showScan;
    if (_searchType == SCSearchTypeScan) {
        _scanButtonWidth.constant = showScan ? 50.0 : 0.0;
    }
}

- (void)setupUI {
    BOOL scanButtonHidden = YES;
    BOOL textFieldHidden = NO;
    BOOL addressButtonHidden = YES;
    self.scanButtonWidth.constant = 0.0;
    switch (self.searchType) {
        case SCSearchTypeNormal:
            break;
            
        case SCSearchTypeScan: {
            scanButtonHidden = NO;
            self.scanButtonWidth.constant = 50.0;
        }
            break;
            
        case SCSearchTypeAddress: {
            textFieldHidden = YES;
            addressButtonHidden = NO;
        }
            break;
            
        default:
            break;
    }
    self.textField.hidden = textFieldHidden;
    self.addressButton.hidden = addressButtonHidden;
    
}

#pragma mark - 按钮事件
- (IBAction)buttonClick:(UIButton *)sender {
    
    if (self.buttonBlock) {
        self.buttonBlock(sender,sender.tag);
    }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (self.textBlock) {
        self.textBlock(textField.text);
    }
    return YES;
}

//- (BOOL)textFieldShouldClear:(UITextField *)textField {
//    if (self.textBlock) {
//        self.textBlock(@"");
//    }
//    return YES;
//}
//
//- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
//    NSMutableString *updatedString = [[NSMutableString alloc] initWithString:textField.text];
//    [updatedString replaceCharactersInRange:range withString:string];
//    if (self.textBlock) {
//        self.textBlock(updatedString);
//    }
//    return YES;
//}

@end
