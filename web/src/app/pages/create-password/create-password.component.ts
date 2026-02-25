import { Component, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormBuilder, FormGroup, ReactiveFormsModule, Validators } from '@angular/forms';
import { Router } from '@angular/router';
import { AuthService } from '../../services/auth.service';
import { InteractiveBackgroundComponent } from '../../components/interactive-background/interactive-background.component';

@Component({
  selector: 'app-create-password',
  standalone: true,
  imports: [CommonModule, ReactiveFormsModule, InteractiveBackgroundComponent],
  templateUrl: './create-password.component.html',
  styleUrl: './create-password.component.css'
})
export class CreatePasswordComponent {
  passwordForm: FormGroup;
  loading = signal(false);
  errorMsg = signal('');
  gradientStyle = '';

  constructor(
    private fb: FormBuilder,
    private auth: AuthService,
    private router: Router
  ) {
    this.passwordForm = this.fb.group({
      password: ['', [Validators.required, Validators.minLength(6)]],
      confirmPassword: ['', Validators.required]
    }, { validators: this.passwordMatchValidator });
  }

  onMouseMove(event: MouseEvent) {
    const x = (event.clientX / window.innerWidth) * 100;
    const y = (event.clientY / window.innerHeight) * 100;

    this.gradientStyle = `
      radial-gradient(
        circle at ${x}% ${y}%,
        hsla(25, 100%, 50%, 0.15) 0%,
        hsla(210, 72%, 52%, 0.1) 25%,
        hsla(25, 100%, 60%, 0.05) 50%,
        transparent 70%
      )
    `;
  }

  passwordMatchValidator(g: FormGroup) {
    return g.get('password')?.value === g.get('confirmPassword')?.value
      ? null : { mismatch: true };
  }

  onSubmit() {
    if (this.passwordForm.invalid) return;
    this.loading.set(true);
    this.errorMsg.set('');

    const newPass = this.passwordForm.value.password;

    // We already have a valid JWT token stored in AuthService
    // We only need to provide userName (can be derived from JWT in backend, 
    // but the API currently requires it in the body). We can fetch the current user to get their ID/email.
    this.auth.getCurrentUser().subscribe({
      next: (user) => {
        this.auth.updateUserCred({
          userName: user.userName,
          userPass: newPass
        }).subscribe({
          next: () => {
            this.loading.set(false);
            const state = window.history.state;
            if (state?.isNewUser) {
              this.router.navigate(['/setup']);
            } else {
              this.router.navigate(['/dashboard']);
            }
          },
          error: (err) => {
            console.error('Failed to create password', err);
            this.errorMsg.set('Failed to save password. Please try again.');
            this.loading.set(false);
          }
        });
      },
      error: (err) => {
        console.error('Failed to get user details', err);
        this.errorMsg.set('Could not authenticate your session.');
        this.loading.set(false);
      }
    });

  }
}
