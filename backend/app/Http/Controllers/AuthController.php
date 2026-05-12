<?php

namespace App\Http\Controllers;
use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use App\Models\User;

class AuthController extends Controller
{
    public function login(Request $request)
    {
        $validator = validator($request->all(), [
            'email' => 'required|email',
            'password' => 'required',
            'is_admin' => 'sometimes|boolean',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'errors' => $validator->errors()
            ], 422);
        }

        $user = User::where('email', $request->email)->first();

        if (!$user) {
            return response()->json([
                'message' => 'User not found'
            ], 404);
        }

        $passwordMatches = false;
        if ($user->password === $request->password) {
            $passwordMatches = true;
        } elseif (str_starts_with($user->password, '$2y$') || str_starts_with($user->password, '$2a$') || str_starts_with($user->password, '$2b$')) {
            $passwordMatches = Hash::check($request->password, $user->password);
        }

        if (!$passwordMatches) {
            return response()->json([
                'message' => 'Invalid credentials'
            ], 401);
        }

        if ($request->filled('is_admin') && $request->is_admin && !$user->isAdmin) {
            return response()->json([
                'message' => 'Admin access denied'
            ], 403);
        }

        return response()->json([
            'message' => 'Login successful',
            'user' => $user
        ], 200);
    }

    public function register(Request $request)
    {
        $validator = validator($request->all(), [
            'firstName' => 'required|max:100',
            'lastName' => 'required|max:100',
            'email' => 'required|email|unique:users,email',
            'password' => 'required|min:6',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'errors' => $validator->errors()
            ], 422);
        }

        $user = User::create([
            'firstName' => $request->firstName,
            'lastName' => $request->lastName,
            'email' => $request->email,
            'password' => Hash::make($request->password),
            'isAdmin' => false,
        ]);

        return response()->json([
            'message' => 'Registration successful',
            'user' => $user
        ], 201);
    }
}