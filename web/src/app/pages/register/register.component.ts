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
      userType: ['USER', [Validators.required]],
      companyName: ['']
    });
  }

  onSubmit() {
    if (this.registerForm.valid) {
      this.isLoading = true;
      this.errorMsg = '';

      this.auth.register(this.registerForm.value).subscribe({
        next: (res) => {
          this.isLoading = false;
          if (res.status === 0) {
            // Auto login or redirect to login? Let's redirect to login
            this.router.navigate(['/login']);
          } else {
            this.errorMsg = res.desc || 'Registration failed';
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
