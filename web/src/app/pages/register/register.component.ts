import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ReactiveFormsModule, FormBuilder, FormGroup, Validators, AbstractControl, ValidationErrors } from '@angular/forms';
import { AuthService } from '../../services/auth.service';
import { Router, RouterModule } from '@angular/router';

@Component({
  selector: 'app-register',
  standalone: true,
  imports: [CommonModule, ReactiveFormsModule, RouterModule],
  templateUrl: './register.component.html',
  styleUrl: './register.component.css'
})
export class RegisterComponent {
  registerForm: FormGroup;
  errorMsg = '';
  isLoading = false;

  passwordMatchValidator(control: AbstractControl): ValidationErrors | null {
    const password = control.get('userPass');
    const confirmPassword = control.get('confirmPassword');

    if (!password || !confirmPassword) {
      return null;
    }

    return password.value === confirmPassword.value ? null : { passwordMismatch: true };
  }

  constructor(
    private fb: FormBuilder,
    private auth: AuthService,
    private router: Router
  ) {
    this.registerForm = this.fb.group({
      userName: ['', [Validators.required, Validators.email]],
      userPass: ['', [Validators.required, Validators.minLength(6)]],
      confirmPassword: ['', [Validators.required]],
      userType: [{ value: 'ADMIN', disabled: true }],
      companyName: ['', [Validators.required]]
    }, { validators: this.passwordMatchValidator });
  }

  onSubmit() {
    if (this.registerForm.valid) {
      this.isLoading = true;
      this.errorMsg = '';

      const registerData = this.registerForm.getRawValue();
      localStorage.removeItem('auth_token');

      this.auth.register(registerData).subscribe({
        next: (res) => {
          this.isLoading = false;
          if (res.responseCode === 0) {
            this.router.navigate(['/setup'], {
              state: { companyName: registerData.companyName }
            });
          } else {
            this.errorMsg = res.responseDesc || 'Registration failed';
          }
        },
        error: (err) => {
          this.isLoading = false;
          this.errorMsg = 'Connection error';
          console.error(err);
        }
      });
    }
  }
}
