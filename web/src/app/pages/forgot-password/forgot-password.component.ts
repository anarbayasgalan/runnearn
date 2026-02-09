import { Component, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ReactiveFormsModule, FormBuilder, FormGroup, Validators } from '@angular/forms';
import { AuthService } from '../../services/auth.service';
import { Router, RouterModule } from '@angular/router';

@Component({
  selector: 'app-forgot-password',
  standalone: true,
  imports: [CommonModule, ReactiveFormsModule, RouterModule],
  templateUrl: './forgot-password.component.html',
  styleUrl: './forgot-password.component.css'
})
export class ForgotPasswordComponent {
  step = signal<'email' | 'otp' | 'password'>('email');
  emailForm: FormGroup;
  otpForm: FormGroup;
  passwordForm: FormGroup;

  errorMsg = signal('');
  successMsg = signal('');
  isLoading = signal(false);
  userName = '';

  constructor(
    private fb: FormBuilder,
    private auth: AuthService,
    private router: Router
  ) {
    this.emailForm = this.fb.group({
      userName: ['', [Validators.required, Validators.email]]
    });

    this.otpForm = this.fb.group({
      otpCode: ['', [Validators.required, Validators.minLength(6), Validators.maxLength(6)]]
    });

    this.passwordForm = this.fb.group({
      newPassword: ['', [Validators.required, Validators.minLength(6)]],
      confirmPassword: ['', [Validators.required]]
    }, { validators: this.passwordMatchValidator });
  }

  passwordMatchValidator(fg: FormGroup) {
    const password = fg.get('newPassword');
    const confirm = fg.get('confirmPassword');
    return password && confirm && password.value === confirm.value ? null : { passwordMismatch: true };
  }

  requestOTP() {
    if (this.emailForm.invalid) return;

    this.isLoading.set(true);
    this.errorMsg.set('');
    this.userName = this.emailForm.value.userName;

    this.auth.requestPasswordReset({ userName: this.userName }).subscribe({
      next: (res) => {
        this.isLoading.set(false);
        if (res.responseCode === 0) {
          this.successMsg.set(res.message || 'OTP sent! Check your email.');
          this.step.set('otp');
        } else {
          this.errorMsg.set(res.responseDesc || 'Failed to send OTP');
        }
      },
      error: (err) => {
        this.isLoading.set(false);
        this.errorMsg.set(err.error?.responseDesc || 'Error sending OTP');
      }
    });
  }

  verifyOTP() {
    if (this.otpForm.invalid) return;

    this.isLoading.set(true);
    this.errorMsg.set('');

    this.auth.verifyOTP({
      userName: this.userName,
      otpCode: this.otpForm.value.otpCode
    }).subscribe({
      next: (res) => {
        this.isLoading.set(false);
        if (res.responseCode === 0) {
          this.successMsg.set('OTP verified!');
          this.step.set('password');
        } else {
          this.errorMsg.set(res.responseDesc || 'Invalid OTP');
        }
      },
      error: (err) => {
        this.isLoading.set(false);
        this.errorMsg.set(err.error?.responseDesc || 'Invalid OTP');
      }
    });
  }

  resetPassword() {
    if (this.passwordForm.invalid) return;

    this.isLoading.set(true);
    this.errorMsg.set('');

    this.auth.resetPassword({
      userName: this.userName,
      otpCode: this.otpForm.value.otpCode,
      newPassword: this.passwordForm.value.newPassword
    }).subscribe({
      next: (res) => {
        this.isLoading.set(false);
        if (res.responseCode === 0) {
          this.successMsg.set('Password reset successfully!');
          setTimeout(() => this.router.navigate(['/login']), 2000);
        } else {
          this.errorMsg.set(res.responseDesc || 'Failed to reset password');
        }
      },
      error: (err) => {
        this.isLoading.set(false);
        this.errorMsg.set(err.error?.responseDesc || 'Error resetting password');
      }
    });
  }
}
