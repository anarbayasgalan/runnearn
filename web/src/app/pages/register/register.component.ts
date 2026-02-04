import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ReactiveFormsModule, FormBuilder, FormGroup, Validators } from '@angular/forms';
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

  constructor(
    private fb: FormBuilder,
    private auth: AuthService,
    private router: Router
  ) {
    this.registerForm = this.fb.group({
      userName: ['', [Validators.required]],
      userPass: ['', [Validators.required, Validators.minLength(6)]],
      userType: [{ value: 'ADMIN', disabled: true }],
      companyName: ['', [Validators.required]]
    });
  }

  onSubmit() {
    if (this.registerForm.valid) {
      this.isLoading = true;
      this.errorMsg = '';

      const registerData = this.registerForm.getRawValue();
      console.log('Registration data being sent:', registerData);

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
